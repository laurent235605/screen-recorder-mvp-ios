import Foundation
import StoreKit

@MainActor
final class MonetizationManager: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var hasPro = false
    @Published var isLoadingProducts = false
    @Published var isPurchaseInProgress = false
    @Published var statusMessage = ""

    private var transactionUpdatesTask: Task<Void, Never>?

    init() {
        observeTransactionUpdates()

        Task {
            await refreshEntitlements()
            await loadProducts()
        }
    }

    deinit {
        transactionUpdatesTask?.cancel()
    }

    func loadProducts() async {
        guard AppConfig.FeatureFlags.monetizationEnabled else {
            statusMessage = "Monetization is disabled."
            return
        }

        isLoadingProducts = true
        defer { isLoadingProducts = false }

        do {
            let fetchedProducts = try await Product.products(for: AppConfig.ProductIDs.all)
            products = sortProducts(fetchedProducts)

            if products.isEmpty {
                statusMessage = "No products are configured yet."
            }
        } catch {
            statusMessage = "Could not load subscriptions: \(error.localizedDescription)"
        }
    }

    func purchase(_ product: Product) async {
        isPurchaseInProgress = true
        defer { isPurchaseInProgress = false }

        do {
            let result = try await product.purchase()
            switch result {
            case let .success(verificationResult):
                let transaction = try Self.verify(verificationResult)
                await transaction.finish()
                await refreshEntitlements()
                statusMessage = hasPro ? "Pro is active." : "Purchase completed."
            case .pending:
                statusMessage = "Purchase is pending approval."
            case .userCancelled:
                statusMessage = "Purchase cancelled."
            @unknown default:
                statusMessage = "Purchase did not complete."
            }
        } catch {
            statusMessage = "Purchase failed: \(error.localizedDescription)"
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            statusMessage = hasPro ? "Purchases restored." : "No active Pro subscription found."
        } catch {
            statusMessage = "Restore failed: \(error.localizedDescription)"
        }
    }

    func refreshEntitlements() async {
        var proEntitlement = false

        for await result in Transaction.currentEntitlements {
            guard let transaction = try? Self.verify(result) else { continue }
            guard AppConfig.ProductIDs.all.contains(transaction.productID) else { continue }
            guard transaction.revocationDate == nil else { continue }
            guard !transaction.isUpgraded else { continue }

            proEntitlement = true
            break
        }

        hasPro = proEntitlement
    }

    private func observeTransactionUpdates() {
        transactionUpdatesTask?.cancel()

        transactionUpdatesTask = Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }

                do {
                    let transaction = try Self.verify(result)
                    await transaction.finish()
                    await self.refreshEntitlements()
                } catch {
                    await MainActor.run {
                        self.statusMessage = "Transaction verification failed."
                    }
                }
            }
        }
    }

    private func sortProducts(_ products: [Product]) -> [Product] {
        let rank = [
            AppConfig.ProductIDs.proMonthly: 0,
            AppConfig.ProductIDs.proYearly: 1,
        ]

        return products.sorted { lhs, rhs in
            let lhsRank = rank[lhs.id] ?? Int.max
            let rhsRank = rank[rhs.id] ?? Int.max

            if lhsRank != rhsRank {
                return lhsRank < rhsRank
            }

            return lhs.displayName < rhs.displayName
        }
    }

    private static func verify<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case let .verified(safe):
            return safe
        case .unverified:
            throw StoreError.failedVerification
        }
    }

    private enum StoreError: LocalizedError {
        case failedVerification

        var errorDescription: String? {
            switch self {
            case .failedVerification:
                return "Transaction verification failed."
            }
        }
    }
}
