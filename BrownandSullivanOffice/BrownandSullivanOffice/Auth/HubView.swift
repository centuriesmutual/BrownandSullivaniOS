import SwiftUI

/// Landing screen: pick **Office** or **PressBox** (Campaign), matching the two
/// products in this monorepo port.
struct HubView: View {
    @EnvironmentObject private var app: AppState

    var body: some View {
        ZStack {
            PressBoxTheme.heroGradient.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    VStack(spacing: 8) {
                        Text("Workspaces")
                            .font(.largeTitle.bold())
                            .foregroundStyle(PressBoxTheme.textPrimary)
                        Text("Choose where you want to sign in")
                            .font(.subheadline)
                            .foregroundStyle(PressBoxTheme.textSecondary)
                    }
                    .padding(.top, 48)

                    VStack(spacing: 16) {
                        workspaceCard(
                            title: "Office Dashboard",
                            subtitle: "Dialer, enrollment, drive, chat & analytics",
                            icon: "building.2.fill",
                            gradient: [Theme.color.primary, Color(hex: 0x4285F4)]
                        ) {
                            app.goToOfficeLogin()
                        }

                        workspaceCard(
                            title: "PressBox",
                            subtitle: "Marketing Hub — campaigns, content & intelligence",
                            icon: "megaphone.fill",
                            gradient: [PressBoxTheme.indigo, PressBoxTheme.indigoDark]
                        ) {
                            app.goToCampaignLogin()
                        }
                    }
                    .padding(.horizontal, 20)

                    Text("Use your organization email on the next screen.")
                        .font(.caption)
                        .foregroundStyle(PressBoxTheme.textSecondary)
                        .padding(.top, 8)
                }
                .padding(.bottom, 40)
            }
        }
    }

    private func workspaceCard(
        title: String,
        subtitle: String,
        icon: String,
        gradient: [Color],
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 56, height: 56)
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(PressBoxTheme.textPrimary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(PressBoxTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title2)
                    .foregroundStyle(PressBoxTheme.indigo.opacity(0.35))
            }
            .padding(18)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HubView().environmentObject(AppState())
}
