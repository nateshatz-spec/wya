import Foundation
import StoreKit
import SwiftUI

class ReviewManager {
    static let shared = ReviewManager()
    
    @MainActor
    func requestReviewIfAppropriate(store: DataStore) {
        let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
        
        // Conditions for requesting a review:
        // 1. User has completed at least 5 sessions
        // 2. User is at least Level 5
        // 3. We haven't requested a review for this version yet
        
        let hasMetSessionGoal = store.totalSessionsCompleted >= 5
        let hasMetLevelGoal = store.level >= 5
        let isNewVersion = store.lastReviewRequestVersion != currentVersion
        
        if hasMetSessionGoal && hasMetLevelGoal && isNewVersion {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
                store.lastReviewRequestVersion = currentVersion
                store.saveAll()
                
                // Analytics
                AnalyticsManager.shared.log(.app_review_requested, params: ["version": currentVersion])
            }
        }
    }
}
