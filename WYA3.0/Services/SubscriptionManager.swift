import Foundation
import StoreKit
import SwiftUI
import Combine

@MainActor
class SubscriptionManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    
    private var updates: Task<Void, Never>? = nil
    
    // Product IDs
    private let productIDs = ["plus_monthly", "plus_yearly"]
    
    @Published private var isSimulatedPremium: Bool = false
    
    var isPremium: Bool {
        isSimulatedPremium || !purchasedProductIDs.isEmpty
    }
    
    func simulatePremium() {
        isSimulatedPremium = true
    }
    
    func toggleSimulatedPremium() {
        isSimulatedPremium.toggle()
    }
    
    init() {
        // Start listening for transaction updates
        updates = observeTransactionUpdates()
        
        // Fetch products and current status
        Task {
            await fetchProducts()
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        updates?.cancel()
    }
    
    func fetchProducts() async {
        do {
            let fetchedProducts = try await Product.products(for: productIDs)
            self.products = fetchedProducts.sorted(by: { $0.price < $1.price })
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try SubscriptionManager.checkVerified(verification)
            await updatePurchasedProducts()
            await transaction.finish()
            return transaction
        case .userCancelled, .pending:
            return nil
        @unknown default:
            return nil
        }
    }
    
    func updatePurchasedProducts() async {
        var purchasedIDs: Set<String> = []
        for await result in StoreKit.Transaction.currentEntitlements {
            do {
                let transaction = try SubscriptionManager.checkVerified(result)
                if transaction.revocationDate == nil {
                    purchasedIDs.insert(transaction.productID)
                }
            } catch {
                print("Transaction verification failed: \(error)")
            }
        }
        self.purchasedProductIDs = purchasedIDs
    }
    
    func restorePurchases() async throws {
        try await AppStore.sync()
        await updatePurchasedProducts()
    }
    
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task.detached {
            for await result in StoreKit.Transaction.updates {
                do {
                    _ = try SubscriptionManager.checkVerified(result)
                    await self.updatePurchasedProducts()
                } catch {
                    print("Transaction update verification failed: \(error)")
                }
            }
        }
    }
    
    nonisolated static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }
}
