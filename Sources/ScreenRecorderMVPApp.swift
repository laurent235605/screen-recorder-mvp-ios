import SwiftUI

@main
struct ScreenRecorderMVPApp: App {
    @StateObject private var monetization = MonetizationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(monetization)
        }
    }
}
