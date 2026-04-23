import SwiftUI

struct MoreView: View {
    @EnvironmentObject var store: DataStore
    @EnvironmentObject var auth: AuthManager
    @Environment(\.dismiss) var dismiss
    @State private var confirmDeletion = false
    
    var body: some View {
        List {
            Section("Cloud Synchronization") {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(CloudSyncService.shared.status.label)
                            .font(.system(size: 15, weight: .bold))
                        if let lastSync = store.lastSyncedAt {
                            Text("Last synced \(lastSync.formatted(date: .abbreviated, time: .shortened))")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        CloudSyncService.shared.push()
                    }) {
                        Image(systemName: "arrow.clockwise.icloud")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Theme.blue)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Section("Account") {
                HStack {
                    Text("Name")
                    Spacer()
                    Text(store.userName)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("Email")
                    Spacer()
                    Text(store.userEmail)
                        .foregroundColor(.secondary)
                }
            }
                Toggle("Haptic Feedback", isOn: $store.hapticsEnabled)
                NavigationLink("Notification Settings") {
                    Text("Notifications")
                }
            }
            
            Section("Help & Support") {
                NavigationLink("Medical Disclaimer") {
                    MedicalDisclaimerView()
                }
                Link("Privacy Policy", destination: URL(string: "https://whatsyouranxiety.com/privacy")!)
                Link("Terms of Service", destination: URL(string: "https://whatsyouranxiety.com/terms")!)
                NavigationLink("About WYA") {
                    VStack(spacing: 20) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 60))
                            .foregroundColor(Theme.blue)
                        
                        Text("WYA 3.0")
                            .font(.system(size: 24, weight: .black))
                        
                        Text("Version \(Bundle.main.releaseVersionNumber ?? "3.0.0") (\(Bundle.main.buildVersionNumber ?? "1"))")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.midGrey)
                        
                        Text("© 2026 What's Your Anxiety")
                            .font(.system(size: 12))
                            .foregroundColor(Theme.lightGrey)
                    }
                    .padding()
                }
            }
            
            Section {
                Button("Sign Out") {
                    auth.signOut()
                }
                
                Button("Delete My Account & Data", role: .destructive) {
                    confirmDeletion = true
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete All Data?", isPresented: $confirmDeletion) {
            Button("Delete Everything", role: .destructive) {
                store.resetAllData()
                auth.deleteAccount()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action is permanent. All your clinical progress, mood history, and settings will be erased forever.")
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
    }
}

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
