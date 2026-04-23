import Foundation
import UserNotifications
import UIKit

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification access granted.")
                self.registerCategories()
            }
        }
    }
    
    private func registerCategories() {
        let goodAction = UNNotificationAction(identifier: "FEELING_GOOD", title: "Feeling Great ✨", options: .foreground)
        let neutralAction = UNNotificationAction(identifier: "FEELING_NEUTRAL", title: "Neutral 😐", options: .foreground)
        let badAction = UNNotificationAction(identifier: "FEELING_BAD", title: "Struggling 🆘", options: .foreground)
        
        let moodCategory = UNNotificationCategory(
            identifier: "MOOD_CHECKIN",
            actions: [goodAction, neutralAction, badAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([moodCategory])
    }
    
    func scheduleDailyCheckin() {
        let content = UNMutableNotificationContent()
        content.title = "Evening Clarity Check"
        content.body = "How was your day, today? Take a moment to ground yourself."
        content.categoryIdentifier = "MOOD_CHECKIN"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 20 // 8 PM
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_checkin", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // Handle actions
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let actionId = response.actionIdentifier
        
        // Use DataStore to log the quick mood
        Task { @MainActor in
            let store = DataStore.shared
            switch actionId {
            case "FEELING_GOOD":
                store.addMoodLog(mood: 5, triggers: [], notes: "Logged via Quick Action")
            case "FEELING_NEUTRAL":
                store.addMoodLog(mood: 3, triggers: [], notes: "Logged via Quick Action")
            case "FEELING_BAD":
                store.addMoodLog(mood: 1, triggers: [], notes: "Logged via Quick Action")
            default:
                break
            }
            store.saveAll()
            completionHandler()
        }
    }
}
