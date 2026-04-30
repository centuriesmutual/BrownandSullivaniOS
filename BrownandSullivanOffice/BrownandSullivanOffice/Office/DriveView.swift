import SwiftUI

struct DriveView: View {
    @EnvironmentObject private var app: AppState
    @State private var search = ""
    @State private var sort: Sort = .modified

    enum Sort: String, CaseIterable, Identifiable {
        case name = "Name"
        case modified = "Modified"
        case kind = "Kind"
        case owner = "Owner"
        var id: String { rawValue }
    }

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            quickFolders
            Divider()
            filesList
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Menu {
                    Button("Upload file…") {}
                    Button("New folder") {}
                    Button("New document") {}
                } label: {
                    Label("New", systemImage: "plus.circle.fill")
                }
            }
            ToolbarItem(placement: .bottomBar) {
                Spacer()
            }
            ToolbarItem(placement: .bottomBar) {
                Menu {
                    Picker("Sort by", selection: $sort) {
                        ForEach(Sort.allCases) { Text($0.rawValue).tag($0) }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down.circle")
                }
            }
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundStyle(Theme.color.textSecondary)
            TextField("Search Drive…", text: $search)
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

    private var quickFolders: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(["My Drive", "Shared with me", "Recent", "Starred", "Trash"], id: \.self) { name in
                    Button {} label: {
                        Label(name, systemImage: icon(for: name))
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .background(Theme.color.surfaceMuted)
                            .foregroundStyle(Theme.color.textPrimary)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Theme.spacing.l)
            .padding(.bottom, 10)
        }
        .background(Color.white)
    }

    private func icon(for label: String) -> String {
        switch label {
        case "Shared with me": "person.2.fill"
        case "Recent": "clock.fill"
        case "Starred": "star.fill"
        case "Trash": "trash.fill"
        default: "internaldrive.fill"
        }
    }

    private var filesList: some View {
        List {
            ForEach(filtered) { file in
                row(for: file)
                    .listRowBackground(Color.white)
            }
        }
        .listStyle(.plain)
    }

    private var filtered: [DriveFile] {
        let base = app.driveFiles.filter {
            search.isEmpty || $0.name.localizedCaseInsensitiveContains(search)
        }
        switch sort {
        case .name: return base.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .modified: return base.sorted { $0.modified < $1.modified }
        case .kind: return base.sorted { $0.kind.rawValue < $1.kind.rawValue }
        case .owner: return base.sorted { $0.owner < $1.owner }
        }
    }

    private func row(for file: DriveFile) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(file.color.opacity(0.15))
                Image(systemName: file.icon).foregroundStyle(file.color)
            }
            .frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(file.name).font(.subheadline.weight(.semibold))
                HStack(spacing: 8) {
                    Text(file.owner).font(.caption).foregroundStyle(Theme.color.textSecondary)
                    if file.kind != .folder {
                        Text("•").font(.caption).foregroundStyle(Theme.color.textSecondary)
                        Text(file.size).font(.caption).foregroundStyle(Theme.color.textSecondary)
                    }
                }
            }
            Spacer()
            Text(file.modified)
                .font(.caption)
                .foregroundStyle(Theme.color.textSecondary)
        }
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {} label: { Label("Delete", systemImage: "trash") }
            Button {} label: { Label("Star", systemImage: "star.fill") }.tint(.yellow)
        }
    }
}

#Preview {
    NavigationStack { DriveView().environmentObject(AppState()) }
}
