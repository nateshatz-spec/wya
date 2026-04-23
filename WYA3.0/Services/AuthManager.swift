import SwiftUI
import Combine
import CryptoKit

// MARK: - Auth Errors
enum AuthError: LocalizedError {
    case invalidEmail, weakPassword, emailInUse, noAccount, wrongPassword, unknown

    var errorDescription: String? {
        switch self {
        case .invalidEmail:    return "Please enter a valid email address."
        case .weakPassword:    return "Password must be at least 6 characters."
        case .emailInUse:      return "An account with this email already exists. Try signing in."
        case .noAccount:       return "No account found with that email. Try signing up."
        case .wrongPassword:   return "Incorrect password. Please try again."
        case .unknown:         return "Something went wrong. Please try again."
        }
    }
}

// MARK: - Auth Manager
class AuthManager: NSObject, ObservableObject {
    @Published var hasCompletedOnboarding: Bool = false
    @Published var userId: String = ""
    @Published var displayName: String = ""

    private let userIdKey = "wya_active_user_id"
    private let authTokenKey = "wya_auth_token"
    private let authMethodKey = "wya_auth_method"
    private let displayNameKey = "wya_display_name"
    private let onboardingCompleteKey = "wya_onboarding_complete"

    override init() {
        super.init()
        restoreSession()
    }

    // MARK: - Restore session
    private func restoreSession() {
        let isDone = UserDefaults.standard.bool(forKey: onboardingCompleteKey)
        guard isDone, let savedId = KeychainHelper.load(key: userIdKey) else { return }
        
        DispatchQueue.main.async {
            self.userId = savedId
            self.displayName = UserDefaults.standard.string(forKey: self.displayNameKey) ?? "Friend"
            self.hasCompletedOnboarding = true
        }
    }

    // MARK: - Sign Up
    func signUp(name: String, email: String, password: String, completion: @escaping (Error?) -> Void) {
        let body: [String: String] = ["email": email, "password": password, "name": name]
        guard let url = URL(string: "\(CloudSyncConfig.baseURL)/api/v1/auth/signup"),
              let data = try? JSONSerialization.data(withJSONObject: body) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(error) }
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let userId = json["userId"] as? String,
                  let token = json["token"] as? String else {
                DispatchQueue.main.async { completion(AuthError.unknown) }
                return
            }
            
            KeychainHelper.save(key: self?.userIdKey ?? "uid", value: userId)
            KeychainHelper.save(key: self?.authTokenKey ?? "token", value: token)
            UserDefaults.standard.set(name, forKey: self?.displayNameKey ?? "name")
            UserDefaults.standard.set(true, forKey: self?.onboardingCompleteKey ?? "done")
            
            DispatchQueue.main.async {
                self?.userId = userId
                self?.displayName = name
                self?.hasCompletedOnboarding = true
                completion(nil)
            }
        }.resume()
    }
    
    // MARK: - Sign In
    func signIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        let body: [String: String] = ["email": email, "password": password]
        guard let url = URL(string: "\(CloudSyncConfig.baseURL)/api/v1/auth/login"),
              let data = try? JSONSerialization.data(withJSONObject: body) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(error) }
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let userId = json["userId"] as? String,
                  let token = json["token"] as? String else {
                DispatchQueue.main.async { completion(AuthError.wrongPassword) }
                return
            }
            
            let name = json["name"] as? String ?? "Friend"
            
            KeychainHelper.save(key: self?.userIdKey ?? "uid", value: userId)
            KeychainHelper.save(key: self?.authTokenKey ?? "token", value: token)
            UserDefaults.standard.set(name, forKey: self?.displayNameKey ?? "name")
            UserDefaults.standard.set(true, forKey: self?.onboardingCompleteKey ?? "done")
            
            DispatchQueue.main.async {
                self?.userId = userId
                self?.displayName = name
                self?.hasCompletedOnboarding = true
                completion(nil)
            }
        }.resume()
    }

    // MARK: - Complete Onboarding (Old, kept for compatibility if needed)
    func completeOnboarding(name: String, email: String) {
        let userId = "user_\(emailHash(email))"
        UserDefaults.standard.set(name, forKey: displayNameKey)
        UserDefaults.standard.set(true, forKey: onboardingCompleteKey)
        KeychainHelper.save(key: userIdKey, value: userId)
        KeychainHelper.save(key: authMethodKey, value: "local_profile")
        
        DispatchQueue.main.async {
            self.userId = userId
            self.displayName = name
            self.hasCompletedOnboarding = true
        }
    }

    // MARK: - Sign Out
    func signOut() {
        // Stop cloud sync
        CloudSyncService.shared.status = .idle
        
        KeychainHelper.delete(key: userIdKey)
        KeychainHelper.delete(key: authTokenKey)
        KeychainHelper.delete(key: authMethodKey)
        UserDefaults.standard.set(false, forKey: onboardingCompleteKey)
        DispatchQueue.main.async {
            self.userId = ""
            self.displayName = ""
            self.hasCompletedOnboarding = false
        }
    }

    // MARK: - Delete Account
    func deleteAccount() {
        // Delete cloud data before signing out
        CloudSyncService.shared.deleteCloudData {
            // Data purged from cloud
        }
        signOut()
    }

    // MARK: - Crypto helpers
    private func emailHash(_ email: String) -> String {
        let data = Data(email.utf8)
        let hash = SHA256.hash(data: data)
        return String(hash.compactMap { String(format: "%02x", $0) }.joined().prefix(16))
    }
}

// MARK: - Keychain Helper
enum KeychainHelper {
    static func save(key: String, value: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    static func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        guard let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
