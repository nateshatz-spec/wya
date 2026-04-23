import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: DataStore
    @EnvironmentObject var tabStore: TabStore
    @EnvironmentObject var auth: AuthManager
    
    @AppStorage("wya_theme_mode") private var themeMode: String = "system"

    var preferredScheme: ColorScheme? {
        switch themeMode {
        case "dark": return .dark
        case "light": return .light
        default: return nil
        }
    }

    var body: some View {
        Group {
            if auth.hasCompletedOnboarding {
                mainAppView
            } else {
                OnboardingView()
            }
        }
        .preferredColorScheme(preferredScheme)
    }

    private var mainAppView: some View {
        TabView(selection: $tabStore.selectedTab) {
            ForEach(tabStore.activeTabs, id: \.self) { tab in
                tab.destination
                    .tabItem {
                        Label(tab.label, systemImage: tab.icon)
                    }
                    .tag(tab)
            }
        }
        .tint(Theme.blue)
        .auraBackground(palette: AuraPalette.fromID(store.selectedAuraID))
        .overlay {
            if store.windDownEnabled {
                Color.orange.opacity(0.15)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .blendMode(.multiply)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DataStore.shared)
        .environmentObject(TabStore.shared)
        .environmentObject(AuthManager())
        .environmentObject(SubscriptionManager())
}
