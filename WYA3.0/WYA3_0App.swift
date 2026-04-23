import SwiftUI

@main
struct WYA3_0App: App {
    @StateObject private var store = DataStore.shared
    @StateObject private var tabStore = TabStore.shared
    @StateObject private var auth = AuthManager()
    @StateObject private var subscriptionManager = SubscriptionManager()

    init() {
        NotificationManager.shared.requestAuthorization()
        NotificationManager.shared.scheduleDailyCheckin()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(tabStore)
                .environmentObject(auth)
                .environmentObject(subscriptionManager)
        }
    }
}
