import Foundation
import SwiftUI
import WidgetKit

class WidgetManager {
    static let shared = WidgetManager()
    
    // Note: In a real app, you would use an App Group ID here
    // let suiteName = "group.com.wya.wellness"
    let suiteName: String? = nil
    
    func syncData(store: DataStore) {
        let defaults = suiteName != nil ? UserDefaults(suiteName: suiteName!) : UserDefaults.standard
        
        // Sync key stats for widgets
        defaults?.set(store.totalXP, forKey: "widget_total_xp")
        defaults?.set(store.level, forKey: "widget_level")
        defaults?.set(store.moodEntries.last?.mood ?? 0, forKey: "widget_last_mood")
        defaults?.set(store.userName, forKey: "widget_user_name")
        defaults?.set(store.selectedAuraID, forKey: "widget_user_aura")
        
        // Notify WidgetCenter to reload
        WidgetCenter.shared.reloadAllTimelines()
    }
}
