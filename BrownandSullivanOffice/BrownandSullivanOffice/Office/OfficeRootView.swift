import SwiftUI

/// Tab-based shell for the Office dashboard. The original web app has a horizontal
/// nav-pill row; on iOS we use a `TabView` (the iOS-idiomatic equivalent).
struct OfficeRootView: View {
    @EnvironmentObject private var app: AppState

    var body: some View {
        TabView(selection: $app.officeTab) {
            ForEach(OfficeTab.allCases) { tab in
                tabRoot(for: tab)
                    .tabItem {
                        Label(tab.title, systemImage: tab.icon)
                    }
                    .tag(tab)
            }
        }
        .tint(Theme.color.primary)
    }

    @ViewBuilder
    private func tabRoot(for tab: OfficeTab) -> some View {
        NavigationStack {
            content(for: tab)
                .navigationTitle(tab.title)
                .navigationBarTitleDisplayMode(tab == .home ? .large : .inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) { brandMark }
                    ToolbarItem(placement: .topBarTrailing) { profileMenu }
                }
                .suiteGroupedBackground()
                .suiteNavigationChrome()
        }
    }

    @ViewBuilder
    private func content(for tab: OfficeTab) -> some View {
        switch tab {
        case .home:       HomeView()
        case .dialer:     DialerView()
        case .email:      EmailView()
        case .calendar:   CalendarTabView()
        case .drive:      DriveView()
        case .chat:       ChatView()
        case .analytics:  AnalyticsView()
        case .settings:   SettingsView()
        case .documents:  DocumentsView()
        case .enrollment: EnrollmentView()
        }
    }

    private var brandMark: some View {
        HStack(spacing: 8) {
            Image(systemName: "square.grid.2x2.fill")
                .font(.title3)
                .foregroundStyle(Theme.gradient.primary)
            VStack(alignment: .leading, spacing: 0) {
                Text("Workspace")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.color.textSecondary)
                Text("Office")
                    .font(.headline)
                    .foregroundStyle(Theme.color.textPrimary)
            }
        }
    }

    private var profileMenu: some View {
        Menu {
            Section {
                Text(app.userName).bold()
                Text(app.userEmail).font(.footnote)
            }
            Divider()
            Picker("Status", selection: $app.disposition) {
                ForEach(AgentDisposition.allCases) { d in
                    Label(d.rawValue, systemImage: d.icon).tag(d)
                }
            }
            Divider()
            Button {
                app.switchToAdmin()
            } label: {
                Label("Switch to Admin", systemImage: "person.crop.circle.badge.checkmark")
            }
            Button(role: .destructive) {
                app.signOut()
            } label: {
                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
            }
        } label: {
            HStack(spacing: 6) {
                StatusDot(color: app.disposition.color, pulse: app.disposition == .active)
                Avatar(initials: app.userInitials, size: 32)
            }
        }
    }
}

#Preview {
    OfficeRootView().environmentObject(AppState())
}
