import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var store: DataStore
    
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var errorMessage: String?
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            // MARK: - Premium Background
            ZStack {
                Color(hex: "0f172a").ignoresSafeArea()
                
                // Animated Mesh Gradient
                Circle()
                    .fill(Color(hex: "1e1b4b"))
                    .frame(width: 400, height: 400)
                    .blur(radius: 100)
                    .offset(x: animateGradient ? -100 : 100, y: animateGradient ? -200 : -100)
                
                Circle()
                    .fill(Theme.blue.opacity(0.3))
                    .frame(width: 300, height: 300)
                    .blur(radius: 80)
                    .offset(x: animateGradient ? 100 : -100, y: animateGradient ? 200 : 100)
            }
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
                
                // Analytics
                AnalyticsManager.shared.log(.paywall_viewed, params: ["context": "locked_feature"])
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 40) {
                    // MARK: - Header
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 100, height: 100)
                                .shadow(color: .white.opacity(0.1), radius: 20)
                            
                            Image(systemName: "crown.fill")
                                .font(.system(size: 44, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, Theme.blueLight],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Theme.blue.opacity(0.5), radius: 10)
                        }
                        .scaleEffect(animateGradient ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: animateGradient)
                        
                        VStack(spacing: 8) {
                            Text("WYA PLUS")
                                .font(.system(size: 14, weight: .black))
                                .kerning(4)
                                .foregroundColor(Theme.blueLight)
                            
                            Text("Your Mind,\nUnlocked.")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Text("Access professional-grade therapy tools and deep clinical insights.")
                                .font(.system(size: 17))
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                    }
                    .padding(.top, 60)
                    
                    // MARK: - Comparison Lab
                    VStack(alignment: .leading, spacing: 20) {
                        Text("WHY UPGRADE?")
                            .font(.system(size: 13, weight: .black))
                            .foregroundColor(.white.opacity(0.5))
                            .kerning(1)
                        
                        VStack(spacing: 16) {
                            comparisonRow(feature: "CBT & DBT Toolkits", plus: true, free: false)
                            comparisonRow(feature: "Sobriety Recovery Lab", plus: true, free: false)
                            comparisonRow(feature: "AI Thought Reframing", plus: true, free: false)
                            comparisonRow(feature: "Exportable Clinical Reports", plus: true, free: false)
                            comparisonRow(feature: "Smart Aura Themes", plus: true, free: false)
                            comparisonRow(feature: "Basic Mood Tracking", plus: true, free: true)
                        }
                    }
                    .padding(24)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    
                    // MARK: - Subscription Options
                    VStack(spacing: 14) {
                        if subscriptionManager.products.isEmpty {
                            mockTierCard(id: "plus_monthly", title: "Monthly (Test)", price: "$4.99")
                            mockTierCard(id: "plus_yearly", title: "Yearly (Test)", price: "$39.99")
                        } else {
                            ForEach(subscriptionManager.products) { product in
                                tierCard(product: product)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // MARK: - Footer Actions
                    VStack(spacing: 20) {
                        if let error = errorMessage {
                            Text(error)
                                .font(.system(size: 13))
                                .foregroundColor(.red)
                        }
                        
                        Button(action: {
                            if let product = selectedProduct {
                                purchase(product: product)
                            }
                        }) {
                            ZStack {
                                if isPurchasing {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text(selectedProduct == nil ? "Select a Plan" : "Start Trial & Upgrade")
                                        .font(.system(size: 18, weight: .bold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(selectedProduct == nil ? Theme.midGrey : Theme.blue)
                            .clipShape(Capsule())
                            .shadow(color: Theme.blue.opacity(selectedProduct == nil ? 0 : 0.3), radius: 10)
                        }
                        .disabled(selectedProduct == nil || isPurchasing)
                        
                        HStack(spacing: 24) {
                            Button("Restore") {
                                Task { try? await subscriptionManager.restorePurchases() }
                            }
                            Text("•").foregroundColor(.white.opacity(0.2))
                            Link("Terms", destination: URL(string: "https://example.com/terms")!)
                            Text("•").foregroundColor(.white.opacity(0.2))
                            Link("Privacy", destination: URL(string: "https://example.com/privacy")!)
                        }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 60)
                }
            }
            
            // Close
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .padding(20)
                }
                Spacer()
            }
        }
    }
    
    private func comparisonRow(feature: String, plus: Bool, free: Bool) -> some View {
        HStack {
            Text(feature)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
            Spacer()
            HStack(spacing: 20) {
                Image(systemName: free ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(free ? .white.opacity(0.6) : .white.opacity(0.2))
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Theme.blueLight)
            }
            .font(.system(size: 14))
        }
    }
    
    @State private var selectedMockID: String = "plus_yearly"

    private func mockTierCard(id: String, title: String, price: String) -> some View {
        let isSelected = selectedMockID == id
        return Button(action: {
            selectedMockID = id
            UISelectionFeedbackGenerator().selectionChanged()
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? Theme.blueLight : .white.opacity(0.2), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    if isSelected {
                        Circle()
                            .fill(Theme.blueLight)
                            .frame(width: 14, height: 14)
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                    Text("Developer Test Mode").font(.system(size: 13)).foregroundColor(.white.opacity(0.6))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(price).font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                    Text(id == "plus_yearly" ? "/yr" : "/mo").font(.system(size: 12)).foregroundColor(.white.opacity(0.5))
                }
            }
            .padding(24)
            .background(isSelected ? Theme.blue.opacity(0.15) : .white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(isSelected ? Theme.blueLight : .white.opacity(0.1), lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }

    private func tierCard(product: Product) -> some View {
        let isSelected = selectedProduct?.id == product.id
        let isYearly = product.id == "plus_yearly"
        return Button(action: { selectedProduct = product; UISelectionFeedbackGenerator().selectionChanged() }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle().stroke(isSelected ? Theme.blueLight : .white.opacity(0.2), lineWidth: 2).frame(width: 24, height: 24)
                    if isSelected { Circle().fill(Theme.blueLight).frame(width: 14, height: 14) }
                }
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(product.displayName).font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                        if isYearly { Text("SAVE 40%").font(.system(size: 10, weight: .black)).foregroundColor(.white).padding(.horizontal, 8).padding(.vertical, 4).background(Theme.blue).clipShape(Capsule()) }
                    }
                    Text(isYearly ? "Includes 3-day free trial" : "Billed monthly").font(.system(size: 13)).foregroundColor(.white.opacity(0.6))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(product.displayPrice).font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                    Text(isYearly ? "/yr" : "/mo").font(.system(size: 12)).foregroundColor(.white.opacity(0.5))
                }
            }
            .padding(24)
            .background(isSelected ? Theme.blue.opacity(0.15) : .white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(isSelected ? Theme.blueLight : .white.opacity(0.1), lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }
    
    private func purchase(product: Product) {
        isPurchasing = true
        Task {
            do {
                let transaction = try await subscriptionManager.purchase(product)
                if transaction != nil {
                    store.isPremium = true
                    store.saveAll()
                    
                    // Analytics
                    AnalyticsManager.shared.log(.subscription_started, params: ["product_id": product.id])
                    
                    dismiss()
                }
            } catch {
                errorMessage = "Purchase failed: \(error.localizedDescription)"
            }
            isPurchasing = false
        }
    }
}
