import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var app: AppState
    @State private var emailNotif = true
    @State private var smsNotif = true
    @State private var desktopNotif = true
    @State private var mobileNotif = true
    @State private var tabletNotif = false
    @State private var compactDensity = false
    @State private var doNotDisturb = false

    var body: some View {
        Form {
            Section {
                HStack(spacing: 14) {
                    Avatar(initials: app.userInitials, size: 64)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(app.userName).font(.headline)
                        Text(app.userEmail).font(.subheadline).foregroundStyle(Theme.color.textSecondary)
                        Text(app.disposition.rawValue.capitalized)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(app.disposition.color.opacity(0.12))
                            .foregroundStyle(app.disposition.color)
                            .clipShape(Capsule())
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Theme.color.textSecondary)
                }
                .padding(.vertical, 4)
            }

            Section("Status") {
                Picker("Disposition", selection: $app.disposition) {
                    ForEach(AgentDisposition.allCases) { d in
                        Label(d.rawValue, systemImage: d.icon).tag(d)
                    }
                }
                Toggle("Do Not Disturb", isOn: $doNotDisturb)
            }

            Section("Notifications") {
                Toggle("Email", isOn: $emailNotif)
                Toggle("SMS", isOn: $smsNotif)
                Toggle("Desktop", isOn: $desktopNotif)
                Toggle("Mobile", isOn: $mobileNotif)
                Toggle("Tablet", isOn: $tabletNotif)
            }

            Section("Appearance") {
                Toggle("Compact density", isOn: $compactDensity)
                NavigationLink("Theme") { ThemePickerView() }
            }

            Section("Integrations") {
                integrationRow("Google Workspace", icon: "g.circle.fill", color: .red, connected: true)
                integrationRow("Microsoft 365",     icon: "m.circle.fill", color: .blue, connected: false)
                integrationRow("Slack",             icon: "number.circle.fill", color: .purple, connected: true)
                integrationRow("Salesforce",        icon: "cloud.fill", color: .cyan, connected: false)
            }

            Section("Account") {
                NavigationLink("Change password") { ChangePasswordView() }
                NavigationLink("Two-factor authentication") { TwoFAView() }
                NavigationLink("Privacy & data") { Text("Privacy & data").padding() }
            }

            Section {
                Button("Switch to Admin") { app.switchToAdmin() }
                Button(role: .destructive) { app.signOut() } label: {
                    Text("Sign Out")
                }
            }

            Section {
                LabeledContent("App Version", value: "1.0.0 (1)")
                LabeledContent("Build", value: "iOS native")
            }
        }
    }

    private func integrationRow(_ name: String, icon: String, color: Color, connected: Bool) -> some View {
        HStack {
            Image(systemName: icon).foregroundStyle(color).font(.title3)
            Text(name)
            Spacer()
            Text(connected ? "Connected" : "Connect")
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10).padding(.vertical, 4)
                .background((connected ? Theme.color.success : Theme.color.primary).opacity(0.12))
                .foregroundStyle(connected ? Theme.color.success : Theme.color.primary)
                .clipShape(Capsule())
        }
    }
}

private struct ThemePickerView: View {
    @State private var choice: String = "Auto"
    var body: some View {
        Form {
            Picker("Mode", selection: $choice) {
                Text("Auto").tag("Auto")
                Text("Light").tag("Light")
                Text("Dark").tag("Dark")
            }
            .pickerStyle(.inline)
        }
        .navigationTitle("Theme")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ChangePasswordView: View {
    @State private var oldPwd = ""
    @State private var newPwd = ""
    @State private var confirm = ""
    var body: some View {
        Form {
            SecureField("Current password", text: $oldPwd)
            SecureField("New password", text: $newPwd)
            SecureField("Confirm new password", text: $confirm)
            Button("Update password") {}
                .disabled(oldPwd.isEmpty || newPwd.isEmpty || newPwd != confirm)
        }
        .navigationTitle("Change password")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct TwoFAView: View {
    @State private var enabled = false
    var body: some View {
        Form {
            Toggle("Enable 2FA", isOn: $enabled)
            if enabled {
                Section("Methods") {
                    Label("Authenticator app", systemImage: "key.fill")
                    Label("SMS code", systemImage: "message.fill")
                    Label("Backup codes", systemImage: "doc.text.fill")
                }
            }
        }
        .navigationTitle("Two-factor authentication")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { SettingsView().environmentObject(AppState()) }
}
