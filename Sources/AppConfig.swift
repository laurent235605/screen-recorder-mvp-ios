import Foundation

enum AppConfig {
    enum ProductIDs {
        static let proMonthly = "com.example.ScreenRecorderMVP.pro.monthly"
        static let proYearly = "com.example.ScreenRecorderMVP.pro.yearly"

        static let all = [proMonthly, proYearly]
    }

    enum FeatureFlags {
        static let monetizationEnabled = true
        static let gateTikTokExportToPro = true
    }
}
