import SwiftUI

/// `dashboard/chat-meetings/page.tsx` — profile + meetings-style chat (simplified).
struct CampaignChatMeetingsView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var role = ""
    @State private var department = ""

    var body: some View {
        Form {
            Section("Your profile") {
                TextField("Name", text: $name)
                TextField("Role", text: $role)
                TextField("Department", text: $department)
                Text("Updates are local-only in this demo.")
                    .font(.caption)
                    .foregroundStyle(PressBoxTheme.textSecondary)
            }
            Section("Quick meetings") {
                Text("Use Messaging for live threads; this screen mirrors the web chat-meetings profile area.")
                    .font(.subheadline)
            }
            Section("Teammates") {
                ForEach(app.campaignInbox) { p in
                    HStack {
                        Text(p.initials)
                            .font(.caption.weight(.bold))
                            .frame(width: 36, height: 36)
                            .background(PressBoxTheme.indigoLight)
                            .clipShape(Circle())
                        VStack(alignment: .leading) {
                            Text(p.name).font(.subheadline.weight(.semibold))
                            Text(p.role).font(.caption).foregroundStyle(PressBoxTheme.textSecondary)
                        }
                        Spacer()
                        Text(p.presence.rawValue.capitalized)
                            .font(.caption2)
                            .foregroundStyle(PressBoxTheme.textSecondary)
                    }
                }
            }
        }
        .navigationTitle("Chat & Meetings")
        .onAppear {
            if name.isEmpty { name = app.campaignUserName }
            if role.isEmpty { role = "Marketer" }
            if department.isEmpty { department = "Growth" }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") { dismiss() }
            }
        }
    }
}

#Preview {
    CampaignChatMeetingsView().environmentObject(AppState())
}
