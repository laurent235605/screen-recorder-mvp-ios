import Foundation

enum AnalyticsEvent: String {
    case paywallShown = "paywall_shown"
    case purchaseTapped = "purchase_tapped"
    case purchaseSuccess = "purchase_success"
    case purchaseRestore = "purchase_restore"
    case exportStarted = "export_started"
    case exportSuccess = "export_success"
    case exportFailed = "export_failed"
    case saveToPhotosTapped = "save_to_photos_tapped"
    case shareTapped = "share_tapped"
}

protocol AnalyticsLogging {
    func log(_ event: AnalyticsEvent, properties: [String: String]?)
}

struct Analytics {
    static var logger: AnalyticsLogging = LocalAnalyticsLogger.shared

    static func log(_ event: AnalyticsEvent, properties: [String: String]? = nil) {
        logger.log(event, properties: properties)
    }
}

final class LocalAnalyticsLogger: AnalyticsLogging {
    static let shared = LocalAnalyticsLogger()

    private init() {}

    func log(_ event: AnalyticsEvent, properties: [String: String]?) {
        let timestamp = Date().ISO8601Format()
        guard let properties, !properties.isEmpty else {
            print("[Analytics] \(timestamp) \(event.rawValue)")
            return
        }

        let propertiesText = properties
            .map { "\($0.key)=\($0.value)" }
            .sorted()
            .joined(separator: ",")
        print("[Analytics] \(timestamp) \(event.rawValue) \(propertiesText)")
    }
}
