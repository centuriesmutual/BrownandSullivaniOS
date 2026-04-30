import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var app: AppState
    @State private var aiInput: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing.l) {
                welcomeHeader
                appsGrid
                meetingsCard
                recentCallsCard
                emailPreviewCard
                aiAssistantCard
                activityCard
            }
            .padding(.horizontal, Theme.spacing.l)
            .padding(.vertical, Theme.spacing.l)
        }
    }

    // MARK: - Sections

    private var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Welcome back, \(firstName)")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Theme.gradient.primary)
            Text("Here's what's happening in your office today")
                .font(.subheadline)
                .foregroundStyle(Theme.color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var firstName: String {
        app.userName.split(separator: " ").first.map(String.init) ?? app.userName
    }

    private var appsGrid: some View {
        TitledCard("Apps", icon: "square.grid.2x2.fill") {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4),
                      spacing: Theme.spacing.l) {
                ForEach(app.shortcuts) { shortcut in
                    IOSAppIcon(title: shortcut.title,
                               icon: shortcut.icon,
                               gradient: shortcut.gradient) {
                        app.officeTab = shortcut.destinationTab
                    }
                }
            }
        }
    }

    private var meetingsCard: some View {
        TitledCard("Today's meetings", icon: "calendar") {
            VStack(spacing: 10) {
                ForEach(app.meetings) { meeting in
                    HStack(spacing: 12) {
                        Rectangle().fill(meeting.accent).frame(width: 4)
                            .clipShape(RoundedRectangle(cornerRadius: 2))
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(meeting.title).font(.subheadline.weight(.semibold))
                                Spacer()
                                Text(meeting.time)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Theme.color.primary)
                            }
                            HStack(spacing: 6) {
                                Image(systemName: "person.2.fill")
                                    .font(.caption2)
                                    .foregroundStyle(Theme.color.textSecondary)
                                Text(meeting.participants.joined(separator: ", "))
                                    .font(.caption)
                                    .foregroundStyle(Theme.color.textSecondary)
                            }
                        }
                        Spacer()
                        Button {} label: {
                            Image(systemName: "video.fill")
                                .padding(8)
                                .background(meeting.accent.opacity(0.12))
                                .foregroundStyle(meeting.accent)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(12)
                    .background(meeting.accent.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }

    private var recentCallsCard: some View {
        TitledCard("Recent calls", icon: "phone.fill") {
            VStack(spacing: 0) {
                ForEach(Array(app.recentCalls.enumerated()), id: \.element.id) { idx, call in
                    HStack(spacing: 12) {
                        Avatar(initials: call.initials, size: 40,
                               gradient: [Color(hex: 0x64748B), Color(hex: 0x475569)])
                        VStack(alignment: .leading, spacing: 4) {
                            Text(call.name).font(.subheadline.weight(.semibold))
                            Text(call.phone).font(.caption).foregroundStyle(Theme.color.textSecondary)
                            HStack(spacing: 6) {
                                ForEach(call.tags, id: \.self) { tag in
                                    ChipBadge(text: tag, color: tagColor(tag))
                                }
                            }
                        }
                        Spacer()
                        Text(call.lastCall).font(.caption).foregroundStyle(Theme.color.textSecondary)
                    }
                    .padding(.vertical, 10)
                    if idx < app.recentCalls.count - 1 {
                        Divider()
                    }
                }
            }
        }
    }

    private func tagColor(_ tag: String) -> Color {
        switch tag.lowercased() {
        case "hot lead": Theme.color.danger
        case "renewal": Theme.color.success
        case "dnc": Theme.color.secondary
        case "quote sent": Theme.color.info
        default: Theme.color.primary
        }
    }

    private var emailPreviewCard: some View {
        TitledCard("Email preview", icon: "envelope.fill",
                   trailing: AnyView(
                    Button("View all") { app.officeTab = .email }
                        .font(.caption.weight(.semibold))
                   )) {
            VStack(spacing: 8) {
                ForEach(app.emails.prefix(3)) { email in
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(email.from).font(.subheadline.weight(.semibold))
                            Text(email.subject).font(.subheadline)
                            Text(email.preview)
                                .font(.caption)
                                .foregroundStyle(Theme.color.textSecondary)
                                .lineLimit(2)
                        }
                        Spacer()
                        Text(email.time).font(.caption).foregroundStyle(Theme.color.textSecondary)
                    }
                    .padding(12)
                    .background(email.unread ? Color(hex: 0xE8F0FE) : Theme.color.surfaceMuted)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(email.unread ? Color(hex: 0xBFDBFE) : Theme.color.border, lineWidth: 1)
                    )
                }
            }
        }
    }

    private var aiAssistantCard: some View {
        TitledCard("AI Assistant", icon: "sparkles") {
            VStack(alignment: .leading, spacing: 10) {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(app.aiMessages) { msg in
                            aiMessageRow(msg)
                        }
                    }
                }
                .frame(maxHeight: 240)

                HStack(spacing: 8) {
                    TextField("Ask anything…", text: $aiInput)
                        .padding(12)
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.color.border, lineWidth: 2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .submitLabel(.send)
                        .onSubmit(send)
                    Button(action: send) {
                        Image(systemName: "paperplane.fill")
                            .padding(12)
                            .background(Theme.gradient.primary)
                            .foregroundStyle(.white)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private func aiMessageRow(_ msg: AIChatMessage) -> some View {
        HStack(alignment: .top, spacing: 10) {
            if msg.role == .assistant {
                ZStack {
                    Circle().fill(Theme.color.info)
                    Image(systemName: "sparkles").foregroundStyle(.white).font(.caption)
                }
                .frame(width: 28, height: 28)
            } else {
                Spacer(minLength: 30)
            }

            Text(msg.body)
                .font(.callout)
                .padding(10)
                .background(msg.role == .user ? Theme.color.primary.opacity(0.10) : Theme.color.surfaceMuted)
                .foregroundStyle(Theme.color.textPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            if msg.role == .user {
                Avatar(initials: app.userInitials, size: 28)
            } else {
                Spacer(minLength: 30)
            }
        }
    }

    private func send() {
        app.sendToAssistant(aiInput)
        aiInput = ""
    }

    private var activityCard: some View {
        TitledCard("Activity", icon: "bolt.fill") {
            VStack(spacing: 10) {
                ForEach(app.activity) { item in
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10).fill(item.tint.opacity(0.15))
                            Image(systemName: item.icon).foregroundStyle(item.tint)
                        }
                        .frame(width: 36, height: 36)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title).font(.subheadline.weight(.semibold))
                            Text(item.detail).font(.caption).foregroundStyle(Theme.color.textSecondary)
                        }
                        Spacer()
                        Text(item.time).font(.caption).foregroundStyle(Theme.color.textSecondary)
                    }
                    .padding(10)
                    .background(Theme.color.surfaceMuted)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeView().environmentObject(AppState())
    }
}
