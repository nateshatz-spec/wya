import SwiftUI

struct DebugMenuView: View {
    @EnvironmentObject var store: DataStore
    @EnvironmentObject var auth: AuthManager
    @EnvironmentObject var subManager: SubscriptionManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("User State") {
                    Toggle("Premium Status", isOn: Binding(
                        get: { store.isPremium },
                        set: { newValue in
                            store.isPremium = newValue
                            store.saveAll()
                            if subManager.isPremium != newValue {
                                subManager.toggleSimulatedPremium()
                            }
                        }
                    ))
                    .tint(Theme.blue)
                    
                    Toggle("Onboarding Completed", isOn: Binding(
                        get: { store.hasCompletedOnboarding },
                        set: { store.hasCompletedOnboarding = $0; store.saveAll() }
                    ))
                    
                    Button("Reset Review Prompt") {
                        store.lastReviewRequestVersion = ""
                        store.totalSessionsCompleted = 0
                        store.saveAll()
                    }
                }
                
                Section("Currency & XP") {
                    Button("Add 1000 XP") {
                        store.addXP(1000)
                    }
                    Button("Add 100 Aura Shards") {
                        store.addAuraShards(100, source: "debug")
                    }
                }
                
                Section("Data Management") {
                    Button("Reset All Data", role: .destructive) {
                        store.resetAllData()
                        dismiss()
                    }
                    
                    Button("Log Mock Analytics Event") {
                        AnalyticsManager.shared.log(.minigame_completed, params: ["type": "debug_mock"])
                    }
                }
                
                Section("App Info") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("3.0.0 (Debug)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Developer Tools")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
