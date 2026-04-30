import SwiftUI

/// Shell for **Marketing Hub** — tabs match `dashboard/layout.tsx`; overflow pages match
/// routes in the Campaign Next.js app.
struct CampaignRootView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var sheet: CampaignSheet?

    enum CampaignSheet: String, Identifiable {
        case balance, createAd, performance, chatMeetings, bi
        var id: String { rawValue }
    }

    var body: some View {
        TabView(selection: $app.campaignTab) {
            ForEach(CampaignTab.allCases) { tab in
                NavigationStack {
                    tabContent(tab)
                        .navigationTitle(tab.title)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar { toolbar }
                }
                .tabItem {
                    Label(
                        horizontalSizeClass == .compact ? tab.shortTitle : tab.title,
                        systemImage: tab.icon
                    )
                }
                .tag(tab)
            }
        }
        .tint(PressBoxTheme.indigo)
        .sheet(item: $sheet) { target in
            NavigationStack {
                switch target {
                case .balance:       CampaignAccountBalanceView()
                case .createAd:      CampaignCreateAdView()
                case .performance:   CampaignPerformanceView()
                case .chatMeetings:  CampaignChatMeetingsView()
                case .bi:            CampaignBIView()
                }
            }
            .environmentObject(app)
        }
    }

    @ViewBuilder
    private func tabContent(_ tab: CampaignTab) -> some View {
        switch tab {
        case .dashboard:   CampaignDashboardView()
        case .messaging:   CampaignMessagingView()
        case .submissions: CampaignSubmitContentView()
        case .intelligence:CampaignIntelligenceView()
        }
    }

    private var toolbar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .topBarLeading) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(PressBoxTheme.indigo.opacity(0.18))
                        Text(app.campaignUserInitials)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(PressBoxTheme.indigoDark)
                    }
                    .frame(width: 36, height: 36)
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(app.campaignUserFirstName)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(PressBoxTheme.textPrimary)
                            if app.campaignExperienceTier == .popular {
                                Text("Popular")
                                    .font(.caption2.weight(.bold))
                                    .padding(.horizontal, 8).padding(.vertical, 3)
                                    .background(Color.orange.opacity(0.2))
                                    .foregroundStyle(Color(hex: 0xC2410C))
                                    .clipShape(Capsule())
                            }
                        }
                        Text("Marketing Hub")
                            .font(.caption2)
                            .foregroundStyle(PressBoxTheme.textSecondary)
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    Button {
                        sheet = .balance
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "wallet.pass.fill")
                            Text("Balance")
                                .font(.subheadline.weight(.semibold))
                        }
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(Color(hex: 0xECFDF5))
                        .foregroundStyle(Color(hex: 0x047857))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)

                    Menu {
                        Button { sheet = .balance } label: {
                            Label("Account Balance", systemImage: "banknote")
                        }
                        Button { sheet = .createAd } label: {
                            Label("Create Ad", systemImage: "sparkles.rectangle.stack")
                        }
                        Button { sheet = .performance } label: {
                            Label("Performance", systemImage: "chart.xyaxis.line")
                        }
                        Button { sheet = .chatMeetings } label: {
                            Label("Chat & Meetings", systemImage: "video.and.waveform")
                        }
                        Button { sheet = .bi } label: {
                            Label("Advanced BI", systemImage: "chart.bar.doc.horizontal")
                        }
                        Divider()
                        Button(role: .destructive) {
                            app.signOut()
                        } label: {
                            Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(PressBoxTheme.textSecondary)
                    }
                }
            }
        }
    }
}

#Preview {
    CampaignRootView().environmentObject(previewCampaign())
}

@MainActor
private func previewCampaign() -> AppState {
    let a = AppState()
    a.activeRoot = .campaign
    return a
}
