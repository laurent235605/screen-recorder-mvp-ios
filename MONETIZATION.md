# Monetization Setup

This project includes a minimal StoreKit 2 subscription scaffold.

## 1) Configure product IDs

Update `Sources/AppConfig.swift` with your real subscription product IDs:

- `AppConfig.ProductIDs.proMonthly`
- `AppConfig.ProductIDs.proYearly`

These IDs must exactly match App Store Connect.

## 2) Create subscriptions in App Store Connect

1. Open your app in App Store Connect.
2. Go to **Monetization** -> **Subscriptions**.
3. Create one subscription group (for Pro).
4. Add at least two auto-renewable subscriptions:
- monthly product (matches `proMonthly`)
- yearly product (matches `proYearly`)
5. Set pricing, localization, and review information.
6. Ensure products are in a state that can be tested in Sandbox/TestFlight.

## 3) Verify entitlement behavior

- `MonetizationManager` loads products using `Product.products(for:)`.
- `hasPro` is computed from `Transaction.currentEntitlements`.
- `ContentView` gates TikTok export when `gateTikTokExportToPro` is enabled.

## 4) Feature flags

`AppConfig.FeatureFlags`:

- `monetizationEnabled`: toggles monetization UI scaffolding.
- `gateTikTokExportToPro`: enforces Pro requirement for TikTok export.

## 5) Local testing

- Use a `.storekit` configuration file for local simulator purchase testing, or
- Use Sandbox testers with a signed build on device/TestFlight.
