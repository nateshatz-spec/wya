import SwiftUI

struct SubscriptionLock: ViewModifier {
    @EnvironmentObject var subManager: SubscriptionManager
    @EnvironmentObject var store: DataStore
    @State private var showingPaywall = false
    
    let featureName: String
    let description: String
    
    var isPremium: Bool {
        subManager.isPremium || store.isPremium
    }
    
    func body(content: Content) -> some View {
        ZStack {
            // The original content is blurred and disabled if not Pro
            content
                .disabled(!isPremium)
                .blur(radius: isPremium ? 0 : 20)
                .grayscale(isPremium ? 0 : 1)
                .animation(.spring(), value: isPremium)
            
            if !isPremium {
                // The Premium Overlay
                VStack(spacing: 24) {
                    // Glassmorphic Icon Container
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.accentColor, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 80, height: 80)
                            .shadow(color: .accentColor.opacity(0.5), radius: 20)
                        
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 8) {
                        Text(featureName)
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                        
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    VStack(spacing: 12) {
                        Text("COMING SOON")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(.accentColor)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.accentColor.opacity(0.1))
                            .clipShape(Capsule())
                        
                        Text("This feature is currently blocked.")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                    }
                    
                    Button {
                        // In a real app, this would show the PaywallView
                        // For now, we'll use a placeholder or the existing PaywallView if it exists
                        showingPaywall = true
                    } label: {
                        Text("Coming Soon")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(LinearGradient(colors: [.accentColor, .blue], startPoint: .leading, endPoint: .trailing))
                            )
                            .shadow(color: .accentColor.opacity(0.3), radius: 10, y: 5)
                    }
                    .padding(.horizontal, 40)
                    .disabled(true)
                    .opacity(0.8)
                    
                    Button("Restore Purchase") {
                        // Restore logic
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding(.vertical, 40)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 30)
                )
                .padding(24)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        // Assuming PaywallView exists based on file discovery
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
    }
}

extension View {
    /// Locks a view behind a subscription wall.
    /// - Parameters:
    ///   - feature: The name of the feature to display in the lock.
    ///   - description: A short description of why they should unlock it.
    func locked(feature: String, description: String = "This feature is coming soon and is currently blocked.") -> some View {
        self.modifier(SubscriptionLock(featureName: feature, description: description))
    }
}
