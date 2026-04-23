import Foundation
import Combine
import Network

// MARK: - Cloud Sync Configuration
struct CloudSyncConfig {
    /// Base URL of your Cloudflare Worker (e.g. "https://wya-api.<your-subdomain>.workers.dev")
    /// Set this after deploying the Worker.
    static let baseURL = Secrets.cloudBaseURL
    static let apiSecret = Secrets.apiSecret
    
    /// Debounce interval in seconds before pushing after a save
    static let pushDebounceSeconds: TimeInterval = 5.0
}

// MARK: - Sync Status
enum SyncStatus: Equatable {
    case idle
    case syncing
    case synced(Date)
    case error(String)
    case offline
    
    var label: String {
        switch self {
        case .idle: return "Not synced"
        case .syncing: return "Syncing…"
        case .synced(let date):
            let fmt = RelativeDateTimeFormatter()
            fmt.unitsStyle = .short
            return "Synced \(fmt.localizedString(for: date, relativeTo: Date()))"
        case .error(let msg): return "Error: \(msg)"
        case .offline: return "Offline"
        }
    }
    
    var systemImage: String {
        switch self {
        case .idle: return "icloud"
        case .syncing: return "arrow.triangle.2.circlepath"
        case .synced: return "checkmark.icloud.fill"
        case .error: return "exclamationmark.icloud.fill"
        case .offline: return "icloud.slash"
        }
    }
}

// MARK: - Cloud Sync Service
class CloudSyncService: ObservableObject {
    static let shared = CloudSyncService()
    
    @Published var status: SyncStatus = .idle
    
    private var pushWorkItem: DispatchWorkItem?
    private let networkMonitor = NWPathMonitor()
    private var isConnected = true
    private var pendingPush = false
    
    private init() {
        // Monitor connectivity
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let wasOffline = !(self?.isConnected ?? true)
                self?.isConnected = (path.status == .satisfied)
                
                if self?.isConnected == true {
                    if wasOffline, self?.status == .offline {
                        self?.status = .idle
                    }
                    // If we queued a push while offline, fire it now
                    if self?.pendingPush == true {
                        self?.pendingPush = false
                        self?.schedulePush()
                    }
                } else {
                    self?.status = .offline
                }
            }
        }
        networkMonitor.start(queue: DispatchQueue.global(qos: .utility))
    }
    
    // MARK: - Push (Upload)
    
    /// Schedule a debounced push of the current DataStore state.
    /// Call this at the end of every `saveAll()`.
    func schedulePush() {
        pushWorkItem?.cancel()
        
        guard isConnected else {
            pendingPush = true
            status = .offline
            return
        }
        
        let work = DispatchWorkItem { [weak self] in
            self?.push()
        }
        pushWorkItem = work
        DispatchQueue.main.asyncAfter(
            deadline: .now() + CloudSyncConfig.pushDebounceSeconds,
            execute: work
        )
    }
    
    /// Immediately push the current DataStore snapshot to the cloud.
    func push() {
        guard isConnected else {
            pendingPush = true
            status = .offline
            return
        }
        
        let store = DataStore.shared
        let userId = KeychainHelper.load(key: "wya_active_user_id") ?? "default"
        let token = KeychainHelper.load(key: "wya_auth_token") ?? CloudSyncConfig.apiSecret
        let snapshot = store.toSnapshot()
        
        guard let body = try? JSONEncoder().encode(snapshot) else {
            status = .error("Encode failed")
            return
        }
        
        status = .syncing
        
        var request = URLRequest(url: url(for: userId))
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.status = .error(error.localizedDescription)
                    return
                }
                guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                    self?.status = .error("Server error")
                    return
                }
                self?.status = .synced(Date())
            }
        }.resume()
    }
    
    // MARK: - Pull (Download & Merge)
    
    /// Pull the latest snapshot from the cloud and apply it to the local DataStore.
    /// Uses "cloud wins if newer" strategy.
    func pull(completion: (() -> Void)? = nil) {
        guard isConnected else {
            status = .offline
            completion?()
            return
        }
        
        let userId = KeychainHelper.load(key: "wya_active_user_id") ?? "default"
        let token = KeychainHelper.load(key: "wya_auth_token") ?? CloudSyncConfig.apiSecret
        
        var request = URLRequest(url: url(for: userId))
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        status = .syncing
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.status = .error(error.localizedDescription)
                    completion?()
                    return
                }
                
                guard let http = response as? HTTPURLResponse else {
                    self?.status = .error("No response")
                    completion?()
                    return
                }
                
                // 404 = no cloud data yet, that's fine
                if http.statusCode == 404 {
                    self?.status = .idle
                    completion?()
                    return
                }
                
                guard (200...299).contains(http.statusCode),
                      let data = data else {
                    self?.status = .error("Server error \(http.statusCode)")
                    completion?()
                    return
                }
                
                // Parse wrapper: { userId, data: {...}, updatedAt }
                guard let wrapper = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let innerData = wrapper["data"],
                      let innerJSON = try? JSONSerialization.data(withJSONObject: innerData) else {
                    self?.status = .error("Parse error")
                    completion?()
                    return
                }
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                guard let snapshot = try? decoder.decode(UserDataSnapshot.self, from: innerJSON) else {
                    self?.status = .error("Decode error")
                    completion?()
                    return
                }
                
                // Merge: cloud wins if its snapshot is newer
                let store = DataStore.shared
                let localDate = store.lastSyncedAt ?? .distantPast
                if snapshot.updatedAt > localDate {
                    store.apply(snapshot: snapshot)
                }
                
                self?.status = .synced(snapshot.updatedAt)
                completion?()
            }
        }.resume()
    }
    
    // MARK: - Delete Cloud Data
    
    /// Delete all cloud data for the current user. Called on account deletion.
    func deleteCloudData(completion: (() -> Void)? = nil) {
        let userId = KeychainHelper.load(key: "wya_active_user_id") ?? "default"
        let token = KeychainHelper.load(key: "wya_auth_token") ?? CloudSyncConfig.apiSecret
        
        var request = URLRequest(url: url(for: userId))
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                completion?()
            }
        }.resume()
    }
    
    // MARK: - Helpers
    
    private func url(for userId: String) -> URL {
        URL(string: "\(CloudSyncConfig.baseURL)/api/v1/users/\(userId)/data")!
    }
}
