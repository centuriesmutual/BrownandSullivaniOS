import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var app: AppState

    var body: some View {
        ZStack {
            switch app.activeRoot {
            case .hub:
                HubView()
                    .transition(.opacity)
            case .officeLogin:
                NavigationStack {
                    LoginView()
                }
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            case .adminLogin:
                NavigationStack {
                    AdminLoginView()
                }
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            case .office:
                OfficeRootView()
                    .transition(.opacity)
            case .officeAdmin:
                AdminView()
                    .transition(.opacity)
            case .campaignLogin:
                NavigationStack {
                    CampaignLoginView()
                }
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            case .campaign:
                CampaignRootView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: app.activeRoot)
    }
}

@MainActor
private func previewState(_ root: AppRoot) -> AppState {
    let s = AppState()
    s.activeRoot = root
    return s
}

#Preview("Hub") {
    ContentView().environmentObject(previewState(.hub))
}

#Preview("Office login") {
    ContentView().environmentObject(previewState(.officeLogin))
}

#Preview("Admin login") {
    ContentView().environmentObject(previewState(.adminLogin))
}

#Preview("Office") {
    ContentView().environmentObject(previewState(.office))
}

#Preview("Admin") {
    ContentView().environmentObject(previewState(.officeAdmin))
}

#Preview("Campaign") {
    ContentView().environmentObject(previewState(.campaign))
}

#Preview("Campaign Popular") {
    ContentView().environmentObject(previewCampaignPopular())
}

@MainActor
private func previewCampaignPopular() -> AppState {
    let s = AppState()
    _ = s.signInCampaign(email: "editor.sarah@pressbox.marketing", password: "demo")
    return s
}
