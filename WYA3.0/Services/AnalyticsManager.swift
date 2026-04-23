import Foundation

class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    private init() {}
    
    enum Event: String {
        case minigame_completed = "minigame_completed"
        case paywall_viewed = "paywall_viewed"
        case subscription_started = "subscription_started"
        case onboarding_step = "onboarding_step"
        case appraisal_wait_started = "appraisal_wait_started"
        case app_review_requested = "app_review_requested"
    }
    
    func log(_ event: Event, params: [String: Any]? = nil) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        var output = "📊 [ANALYTICS] \(timestamp) - \(event.rawValue)"
        
        if let params = params {
            output += " | Params: \(params)"
        }
        
        // In a real app, this would send to Firebase/Mixpanel/etc.
        print(output)
    }
}
