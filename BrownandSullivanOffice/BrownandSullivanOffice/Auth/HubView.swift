import SwiftUI

/// Landing screen: pick **Office** or **PressBox** (Campaign), matching the two
/// products in this monorepo port.
struct HubView: View {
    @EnvironmentObject private var app: AppState

    var body: some View {
        ZStack {
            Theme.Suite.chromeBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Image(systemName: "square.stack.3d.up.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(Theme.gradient.primary)
                            .padding(.top, 36)
                        Text("Google / Apple–style workspace")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Theme.color.textSecondary)
                        Text("Choose where to sign in")
                            .font(.largeTitle.bold())
                            .foregroundStyle(Theme.color.textPrimary)
                        Text("Office for agents, Admin for operators, PressBox for marketing.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.color.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 24)

                    VStack(spacing: 14) {
                        workspaceCard(
                            title: "Office",
                            subtitle: "Agents · phone, mail, Drive, calendar, chat",
                            icon: "building.2.fill",
                            gradient: [Theme.color.primary, Color(hex: 0x4285F4)]
                        ) {
                            app.goToOfficeLogin()
                        }

                        workspaceCard(
                            title: "Admin",
                            subtitle: "Operators · users, system health, audit activity",
                            icon: "shield.lefthalf.filled",
                            gradient: [Color(hex: 0xDC2626), Color(hex: 0x991B1B)]
                        ) {
                            app.goToAdminLogin()
                        }

                        workspaceCard(
                            title: "PressBox",
                            subtitle: "Marketing Hub · campaigns, content, intelligence",
                            icon: "megaphone.fill",
                            gradient: [PressBoxTheme.indigo, PressBoxTheme.indigoDark]
                        ) {
                            app.goToCampaignLogin()
                        }
                    }
                    .padding(.horizontal, 20)

                    Text("Use your organization email on the next screen.")
                        .font(.caption)
                        .foregroundStyle(Theme.color.textSecondary)
                        .padding(.top, 4)
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
                        .foregroundStyle(Theme.color.textPrimary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Theme.color.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Theme.color.textSecondary.opacity(0.5))
            }
            .padding(18)
            .background(Theme.Suite.elevatedSurface)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Theme.Suite.separator.opacity(0.85), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.06), radius: 14, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HubView().environmentObject(AppState())
}
