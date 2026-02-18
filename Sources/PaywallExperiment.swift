import Foundation
import StoreKit

enum PaywallVariant: String, CaseIterable {
    case controlA = "control_a"
    case valueFirstB = "value_first_b"

    var headline: String {
        switch self {
        case .controlA:
            return "Upgrade to Pro"
        case .valueFirstB:
            return "Create TikTok-ready clips faster"
        }
    }

    var subtitle: String {
        switch self {
        case .controlA:
            return "Unlock TikTok 9:16 export and future premium features."
        case .valueFirstB:
            return "Unlock TikTok 9:16 export, faster social sharing, and upcoming pro tools."
        }
    }

    var productOrder: [String] {
        switch self {
        case .controlA:
            return [AppConfig.ProductIDs.proMonthly, AppConfig.ProductIDs.proYearly]
        case .valueFirstB:
            return [AppConfig.ProductIDs.proYearly, AppConfig.ProductIDs.proMonthly]
        }
    }
}

enum PaywallExperiment {
    private static let defaultsKey = "paywall_variant"

    static func assignedVariant() -> PaywallVariant {
        let defaults = UserDefaults.standard

        if let raw = defaults.string(forKey: defaultsKey),
           let existing = PaywallVariant(rawValue: raw) {
            return existing
        }

        let assigned = PaywallVariant.allCases.randomElement() ?? .controlA
        defaults.set(assigned.rawValue, forKey: defaultsKey)
        return assigned
    }

    static func orderedProducts(from products: [Product], variant: PaywallVariant) -> [Product] {
        let byID = Dictionary(uniqueKeysWithValues: products.map { ($0.id, $0) })
        let ordered = variant.productOrder.compactMap { byID[$0] }

        let leftovers = products
            .filter { !variant.productOrder.contains($0.id) }
            .sorted { $0.displayName < $1.displayName }

        return ordered + leftovers
    }
}
