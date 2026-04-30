import SwiftUI

struct ChatView: View {
    @EnvironmentObject private var app: AppState
    @State private var search = ""
    @State private var selected: ChatContact?

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            list
        }
        .navigationDestination(item: $selected) { contact in
            ChatThreadView(contact: contact)
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button { } label: {
                    Label("New chat", systemImage: "square.and.pencil")
                }
            }
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundStyle(Theme.color.textSecondary)
            TextField("Search people…", text: $search)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
        .padding(12)
        .background(Theme.color.surfaceMuted)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, Theme.spacing.l)
        .padding(.vertical, 10)
        .background(Color.white)
    }

    private var list: some View {
        List {
            ForEach(filteredContacts) { contact in
                Button { selected = contact } label: { row(contact) }
                    .listRowBackground(Color.white)
            }
        }
        .listStyle(.plain)
    }

    private var filteredContacts: [ChatContact] {
        if search.isEmpty { return app.chatContacts }
        return app.chatContacts.filter {
            $0.name.localizedCaseInsensitiveContains(search) ||
            $0.email.localizedCaseInsensitiveContains(search)
        }
    }

    private func row(_ contact: ChatContact) -> some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                Avatar(initials: contact.initials, size: 44)
                if contact.online {
                    Circle().fill(Theme.color.success)
                        .frame(width: 12, height: 12)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(contact.name).font(.subheadline.weight(.semibold))
                    Spacer()
                    Text(contact.lastTime).font(.caption).foregroundStyle(Theme.color.textSecondary)
                }
                Text(contact.lastMessage)
                    .font(.caption)
                    .foregroundStyle(Theme.color.textSecondary)
                    .lineLimit(2)
            }
        }
        .contentShape(Rectangle())
        .padding(.vertical, 4)
    }
}

struct ChatThreadView: View {
    @EnvironmentObject private var app: AppState
    let contact: ChatContact
    @State private var input: String = ""

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(app.messages(for: contact)) { msg in
                            messageBubble(msg).id(msg.id)
                        }
                    }
                    .padding(Theme.spacing.l)
                }
                .onChange(of: app.chatThreads[contact.id]?.count) { _, _ in
                    if let last = app.chatThreads[contact.id]?.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            inputBar
        }
        .navigationTitle(contact.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(Theme.color.background)
    }

    private func messageBubble(_ msg: ChatMessage) -> some View {
        HStack {
            if msg.isMine { Spacer(minLength: 40) }
            VStack(alignment: msg.isMine ? .trailing : .leading, spacing: 2) {
                Text(msg.body)
                    .padding(10)
                    .background(msg.isMine ? Theme.color.primary : Color.white)
                    .foregroundStyle(msg.isMine ? Color.white : Theme.color.textPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                Text(msg.timestamp)
                    .font(.caption2)
                    .foregroundStyle(Theme.color.textSecondary)
            }
            if !msg.isMine { Spacer(minLength: 40) }
        }
    }

    private var inputBar: some View {
        HStack(spacing: 8) {
            TextField("Message", text: $input)
                .padding(10)
                .background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.color.border, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .submitLabel(.send)
                .onSubmit(send)
            Button(action: send) {
                Image(systemName: "paperplane.fill")
                    .padding(10)
                    .background(Theme.gradient.primary)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(input.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(10)
        .background(Color.white)
        .overlay(Rectangle().fill(Theme.color.border).frame(height: 1), alignment: .top)
    }

    private func send() {
        app.sendMessage(to: contact, body: input)
        input = ""
    }
}

#Preview {
    NavigationStack { ChatView().environmentObject(AppState()) }
}
