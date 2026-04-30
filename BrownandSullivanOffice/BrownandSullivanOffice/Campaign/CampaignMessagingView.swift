import SwiftUI

/// `dashboard/messaging/page.tsx` — inbox + conversation.
struct CampaignMessagingView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedId: Int = 1
    @State private var draft = ""

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                HStack(spacing: 0) {
                    inboxListCompact
                        .frame(maxWidth: 340)
                    Divider()
                    threadView(conversationId: selectedId)
                }
            } else {
                NavigationStack {
                    inboxListWithNavigation
                }
            }
        }
        .background(PressBoxTheme.background)
        .onAppear {
            if app.campaignInbox.first(where: { $0.id == selectedId }) == nil {
                selectedId = app.campaignInbox.first?.id ?? 1
            }
        }
    }

    private var inboxListCompact: some View {
        List {
            ForEach(app.campaignInbox) { person in
                Button {
                    selectedId = person.id
                } label: {
                    inboxRow(person)
                }
                .listRowBackground(selectedId == person.id ? PressBoxTheme.indigoLight.opacity(0.45) : Color.clear)
            }
        }
        .listStyle(.plain)
    }

    private var inboxListWithNavigation: some View {
        List(app.campaignInbox) { person in
            NavigationLink(value: person.id) {
                inboxRow(person)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Messaging")
        .navigationDestination(for: Int.self) { id in
            threadView(conversationId: id)
                .navigationTitle(name(for: id))
        }
    }

    private func name(for id: Int) -> String {
        app.campaignInbox.first(where: { $0.id == id })?.name ?? "Chat"
    }

    private func inboxRow(_ person: CampaignInboxPerson) -> some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(PressBoxTheme.indigo.opacity(0.2))
                    .frame(width: 44, height: 44)
                Text(person.initials)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(PressBoxTheme.indigo)
                Circle()
                    .fill(presenceColor(person.presence))
                    .frame(width: 10, height: 10)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .offset(x: 2, y: 2)
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(person.name).font(.subheadline.weight(.semibold))
                    Spacer()
                    Text(person.timestamp).font(.caption2).foregroundStyle(PressBoxTheme.textSecondary)
                }
                Text(person.role).font(.caption).foregroundStyle(PressBoxTheme.textSecondary)
                Text(person.lastMessage)
                    .font(.caption)
                    .foregroundStyle(PressBoxTheme.textSecondary)
                    .lineLimit(2)
            }
            if person.unread > 0 {
                Text("\(person.unread)")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(6)
                    .background(PressBoxTheme.indigo)
                    .clipShape(Circle())
            }
        }
        .padding(.vertical, 4)
    }

    private func threadView(conversationId: Int) -> some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(app.campaignMessages(for: conversationId)) { msg in
                        HStack {
                            if msg.isOwn { Spacer(minLength: 40) }
                            VStack(alignment: msg.isOwn ? .trailing : .leading, spacing: 2) {
                                Text(msg.content)
                                    .font(.subheadline)
                                    .padding(12)
                                    .background(msg.isOwn ? PressBoxTheme.indigo : Color.white)
                                    .foregroundStyle(msg.isOwn ? Color.white : PressBoxTheme.textPrimary)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                Text(msg.timestamp)
                                    .font(.caption2)
                                    .foregroundStyle(PressBoxTheme.textSecondary)
                            }
                            if !msg.isOwn { Spacer(minLength: 40) }
                        }
                    }
                }
                .padding()
            }
            HStack(spacing: 8) {
                TextField("Message", text: $draft)
                    .padding(10)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(PressBoxTheme.border))
                Button {
                    app.sendCampaignMessage(conversationId: conversationId, text: draft)
                    draft = ""
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(PressBoxTheme.indigo)
                        .clipShape(Circle())
                }
                .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
            .background(Color.white)
            .overlay(Rectangle().frame(height: 1).foregroundStyle(PressBoxTheme.border), alignment: .top)
        }
    }

    private func presenceColor(_ p: CampaignPresence) -> Color {
        switch p {
        case .online: Color(hex: 0x22C55E)
        case .away: Color(hex: 0xF59E0B)
        case .offline: Color(hex: 0x9CA3AF)
        }
    }
}

#Preview {
    CampaignMessagingView().environmentObject(AppState())
}
