import SwiftUI

@main
struct BrownandSullivanOfficeApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(.light) // Match the web app's bright theme. Remove for system-driven.
        }
    }
}
