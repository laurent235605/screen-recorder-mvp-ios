import StoreKit
import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var monetization: MonetizationManager
    @Environment(\.dismiss) private var dismiss

    private var displayedProducts: [Product] {
        PaywallExperiment.orderedProducts(from: monetization.products, variant: monetization.paywallVariant)
    }

    private var hasAtLeastOneProduct: Bool {
        !displayedProducts.isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text(monetization.paywallVariant.headline)
                    .font(.title2)
                    .bold()

                Text(monetization.paywallVariant.subtitle)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                if monetization.isLoadingProducts {
                    ProgressView("Loading subscriptions...")
                } else {
                    if hasAtLeastOneProduct {
                        VStack(spacing: 10) {
                            ForEach(displayedProducts, id: \.id) { product in
                                PaywallProductCard(
                                    title: product.displayName,
                                    product: product,
                                    isBusy: monetization.isPurchaseInProgress,
                                    action: { selected in
                                        Task {
                                            await monetization.purchase(selected)
                                        }
                                    }
                                )
                            }
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Subscriptions are currently unavailable.", systemImage: "exclamationmark.triangle")
                                .font(.headline)
                            Text("Please check your connection and try again. If this persists, product IDs may be misconfigured.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            Button("Retry Loading Plans") {
                                Task {
                                    await monetization.loadProducts(forceReload: true)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                    }
                }

                Button("Restore Purchases") {
                    Task {
                        await monetization.restorePurchases()
                    }
                }
                .buttonStyle(.bordered)
                .disabled(monetization.isPurchaseInProgress || monetization.isLoadingProducts)

                Text(monetization.hasPro ? "Pro is active on this account." : monetization.statusMessage)
                    .font(.footnote)
                    .foregroundColor(monetization.hasPro ? .green : .secondary)
                    .multilineTextAlignment(.center)

                Spacer(minLength: 0)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await monetization.loadProducts()
            await monetization.refreshEntitlements()
        }
        .onAppear {
            Analytics.log(.paywallShown, properties: [
                "paywall_variant": monetization.paywallVariant.rawValue,
                "entry_point": "paywall_sheet",
            ])
        }
    }
}

private struct PaywallProductCard: View {
    let title: String
    let product: Product
    let isBusy: Bool
    let action: (Product) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)

            Text(product.description)
                .font(.footnote)
                .foregroundColor(.secondary)

            HStack {
                Text(product.displayPrice)
                    .font(.title3)
                    .bold()

                Spacer()

                Button("Buy") {
                    action(product)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isBusy)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}
