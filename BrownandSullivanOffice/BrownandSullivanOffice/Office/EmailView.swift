import SwiftUI

struct EmailView: View {
    @EnvironmentObject private var app: AppState
    @State private var search: String = ""
    @State private var showCompose: Bool = false
    @State private var selected: EmailMessage?

    var body: some View {
        VStack(spacing: 0) {
            folderRail
            Divider()
            list
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    showCompose = true
                } label: {
                    Label("Compose", systemImage: "square.and.pencil")
                }
            }
        }
        .sheet(isPresented: $showCompose) { ComposeSheet() }
        .navigationDestination(item: $selected) { email in
            EmailDetailView(email: email)
        }
    }

    private var folderRail: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(EmailFolder.allCases) { folder in
                    Button { app.emailFolder = folder } label: {
                        HStack(spacing: 6) {
                            Image(systemName: folder.systemImage)
                            Text(folder.rawValue).font(.subheadline.weight(.semibold))
                            if folder == .inbox && app.unreadCount > 0 {
                                Text("\(app.unreadCount)")
                                    .font(.caption2.weight(.bold))
                                    .padding(.horizontal, 6).padding(.vertical, 2)
                                    .background(Theme.color.primary)
                                    .foregroundStyle(.white)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(app.emailFolder == folder
                                    ? Theme.color.primary
                                    : Theme.color.surfaceMuted)
                        .foregroundStyle(app.emailFolder == folder
                                         ? Color.white
                                         : Theme.color.textPrimary)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Theme.spacing.l)
            .padding(.vertical, 10)
        }
        .background(Color.white)
    }

    private var list: some View {
        List {
            Section {
                ForEach(filteredEmails) { email in
                    Button {
                        selected = email
                        app.markRead(email)
                    } label: {
                        emailRow(email)
                    }
                    .listRowBackground(email.unread ? Color(hex: 0xF0F9FF) : Color.white)
                    .swipeActions(edge: .leading) {
                        Button {
                            app.toggleStar(email)
                        } label: {
                            Label("Star", systemImage: email.starred ? "star.slash" : "star.fill")
                        }
                        .tint(.yellow)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            // demo only
                        } label: {
                            Label("Trash", systemImage: "trash")
                        }
                    }
                }
            } header: {
                searchBar
            }
        }
        .listStyle(.plain)
    }

    private var filteredEmails: [EmailMessage] {
        let base = app.visibleEmails
        guard !search.isEmpty else { return base }
        return base.filter {
            $0.subject.localizedCaseInsensitiveContains(search) ||
            $0.from.localizedCaseInsensitiveContains(search) ||
            $0.preview.localizedCaseInsensitiveContains(search)
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundStyle(Theme.color.textSecondary)
            TextField("Search emails…", text: $search)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
        .padding(10)
        .background(Theme.color.surfaceMuted)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
    }

    private func emailRow(_ email: EmailMessage) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Avatar(initials: String(email.from.prefix(2)), size: 40,
                       gradient: [Theme.color.info, Theme.color.primary])
                if email.unread {
                    Circle().stroke(Color.white, lineWidth: 2)
                        .background(Circle().fill(Theme.color.primary))
                        .frame(width: 12, height: 12)
                        .offset(x: 14, y: -14)
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(email.from)
                        .font(.subheadline.weight(email.unread ? .bold : .semibold))
                        .foregroundStyle(Theme.color.textPrimary)
                    if email.starred {
                        Image(systemName: "star.fill").foregroundStyle(.yellow).font(.caption)
                    }
                    Spacer()
                    Text(email.time).font(.caption).foregroundStyle(Theme.color.textSecondary)
                }
                Text(email.subject)
                    .font(.subheadline.weight(email.unread ? .semibold : .regular))
                    .foregroundStyle(Theme.color.textPrimary)
                Text(email.preview)
                    .font(.caption)
                    .foregroundStyle(Theme.color.textSecondary)
                    .lineLimit(2)
            }
        }
        .contentShape(Rectangle())
        .padding(.vertical, 4)
    }
}

struct EmailDetailView: View {
    @EnvironmentObject private var app: AppState
    let email: EmailMessage

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.spacing.l) {
                Text(email.subject)
                    .font(.title2.weight(.bold))
                HStack {
                    Avatar(initials: String(email.from.prefix(2)), size: 44)
                    VStack(alignment: .leading) {
                        Text(email.from).font(.subheadline.weight(.semibold))
                        Text("to me").font(.caption).foregroundStyle(Theme.color.textSecondary)
                    }
                    Spacer()
                    Text(email.time).font(.caption).foregroundStyle(Theme.color.textSecondary)
                }
                Divider()
                Text(email.body).font(.body).foregroundStyle(Theme.color.textPrimary)
                Spacer(minLength: 60)
            }
            .padding(Theme.spacing.l)
        }
        .navigationTitle("Message")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button { app.toggleStar(email) } label: {
                        Label(email.starred ? "Unstar" : "Star",
                              systemImage: email.starred ? "star.slash" : "star.fill")
                    }
                    Button(role: .destructive) {} label: {
                        Label("Move to Trash", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            ToolbarItem(placement: .bottomBar) {
                Button { } label: { Label("Reply", systemImage: "arrowshape.turn.up.left") }
            }
        }
    }
}

private struct ComposeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var to = ""
    @State private var subject = ""
    @State private var body = ""

    var body: some View {
        NavigationStack {
            Form {
                Section { TextField("To", text: $to).keyboardType(.emailAddress) }
                Section { TextField("Subject", text: $subject) }
                Section("Message") {
                    TextEditor(text: $body).frame(minHeight: 200)
                }
            }
            .navigationTitle("New message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send") { dismiss() }
                        .disabled(to.isEmpty || subject.isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        EmailView().environmentObject(AppState())
    }
}
