import AppTrackingTransparency
import AdSupport
import Foundation

/// Manages App Tracking Transparency (ATT) authorization.
/// Apple requires ATT permission to be requested before accessing
/// the Advertising Identifier (IDFA) or passing data to ad networks.
class ATTManager {
    static let shared = ATTManager()

    private init() {}

    /// The IDFA (Advertising Identifier), available only when tracking is authorized.
    var advertisingIdentifier: UUID? {
        guard ATTrackingManager.trackingAuthorizationStatus == .authorized else {
            return nil
        }
        return ASIdentifierManager.shared().advertisingIdentifier
    }

    /// Whether the user has granted tracking authorization.
    var isTrackingAuthorized: Bool {
        ATTrackingManager.trackingAuthorizationStatus == .authorized
    }

    /// Current raw ATT authorization status.
    var authorizationStatus: ATTrackingManager.AuthorizationStatus {
        ATTrackingManager.trackingAuthorizationStatus
    }

    /// Requests ATT tracking authorization from the user.
    /// Must be called from the main thread and only after the app's first screen has appeared.
    /// Apple enforces that the prompt cannot appear during app launch, so this is deferred.
    ///
    /// - Parameter completion: Called with the granted authorization status.
    func requestAuthorization(completion: ((ATTrackingManager.AuthorizationStatus) -> Void)? = nil) {
        // ATT prompt must be presented after the app's first UI has loaded.
        ATTrackingManager.requestTrackingAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("🔍 [ATT] Tracking authorized — IDFA available.")
                case .denied:
                    print("🚫 [ATT] Tracking denied by user.")
                case .restricted:
                    print("⚠️ [ATT] Tracking restricted (parental controls or MDM).")
                case .notDetermined:
                    print("❓ [ATT] Tracking status not yet determined.")
                @unknown default:
                    print("❓ [ATT] Unknown tracking status.")
                }
                completion?(status)
            }
        }
    }
}
