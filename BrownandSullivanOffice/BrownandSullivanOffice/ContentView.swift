import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var app: AppState

    var body: some View {
        ZStack {
            switch app.activeRoot {
            case .login:
                LoginView()
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            case .office:
                OfficeRootView()
                    .transition(.opacity)
            case .admin:
                AdminView()
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

#Preview("Login") {
    ContentView().environmentObject(previewState(.login))
}

#Preview("Office") {
    ContentView().environmentObject(previewState(.office))
}

#Preview("Admin") {
    ContentView().environmentObject(previewState(.admin))
}
