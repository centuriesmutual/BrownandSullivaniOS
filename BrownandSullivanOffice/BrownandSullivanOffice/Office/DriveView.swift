import SwiftUI

/// Dropbox-style cloud drive: sync status, shelves, list/grid, and file actions.
struct DriveView: View {
    @EnvironmentObject private var app: AppState
    @State private var search = ""
    @State private var sort: Sort = .modified
    @State private var shelf: Shelf = .myDrive
    @State private var useGrid = false

    enum Sort: String, CaseIterable, Identifiable {
        case name = "Name"
        case modified = "Modified"
        case kind = "Kind"
        case owner = "Owner"
        var id: String { rawValue }
    }

    enum Shelf: String, CaseIterable, Identifiable {
        case myDrive = "My Drive"
        case shared = "Shared"
        case recent = "Recent"
        case starred = "Starred"
        case trash = "Trash"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .myDrive: "internaldrive.fill"
            case .shared: "person.2.fill"
            case .recent: "clock.fill"
            case .starred: "star.fill"
            case .trash: "trash.fill"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "folder.fill")
                        .foregroundStyle(Theme.Suite.cloudBlue)
                    Text(shelf.rawValue)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Theme.color.textPrimary)
                    Spacer()
                    Button {
                        useGrid.toggle()
                    } label: {
                        Image(systemName: useGrid ? "list.bullet" : "square.grid.2x2")
                            .font(.title3)
                            .foregroundStyle(Theme.Suite.cloudBlue)
                            .padding(10)
                            .background(Theme.Suite.cloudBlueSoft.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(useGrid ? "Show as list" : "Show as grid")
                }
                .padding(.horizontal, Theme.spacing.l)

                CloudSyncStatusRow(isSynced: true, subtitle: shelf == .shared ? "Shared links" : "All devices")

                searchField
                shelfChips
            }
            .padding(.vertical, 12)
            .background(Theme.Suite.chromeBackground)

            Divider()

            if useGrid {
                gridFiles
            } else {
                listFiles
            }
        }
        .suiteGroupedBackground()
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Menu {
                    Button {} label: {
                        Label("Upload file…", systemImage: "arrow.up.doc")
                    }
                    Button {} label: {
                        Label("New folder", systemImage: "folder.badge.plus")
                    }
                    Button {} label: {
                        Label("New document", systemImage: "doc.badge.plus")
                    }
                } label: {
                    Label("New", systemImage: "plus.circle.fill")
                        .foregroundStyle(Theme.Suite.cloudBlue)
                }
            }
            ToolbarItem(placement: .bottomBar) { Spacer() }
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

    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Theme.color.textSecondary)
            TextField("Search in \(shelf.rawValue)…", text: $search)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
        .padding(12)
        .background(Theme.Suite.elevatedSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Theme.color.border, lineWidth: 1)
        )
        .padding(.horizontal, Theme.spacing.l)
    }

    private var shelfChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Shelf.allCases) { s in
                    Button {
                        shelf = s
                    } label: {
                        Label(s.rawValue, systemImage: s.icon)
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(shelf == s ? Theme.Suite.cloudBlue : Theme.Suite.elevatedSurface)
                            .foregroundStyle(shelf == s ? Color.white : Theme.color.textPrimary)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(shelf == s ? Color.clear : Theme.Suite.separator, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Theme.spacing.l)
        }
    }

    private var listFiles: some View {
        List {
            Section {
                ForEach(filtered) { file in
                    row(for: file)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Theme.Suite.elevatedSurface)
                }
            } header: {
                Text("Files")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.color.textSecondary)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

    private var gridFiles: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 150), spacing: 14)],
                spacing: 14
            ) {
                ForEach(filtered) { file in
                    gridCell(for: file)
                }
            }
            .padding(Theme.spacing.l)
        }
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

    private func folderAccent(for file: DriveFile) -> Color {
        file.kind == .folder ? Theme.Suite.cloudBlue : file.color
    }

    private func row(for file: DriveFile) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(folderAccent(for: file).opacity(file.kind == .folder ? 0.18 : 0.12))
                Image(systemName: file.icon)
                    .font(.title3)
                    .foregroundStyle(folderAccent(for: file))
            }
            .frame(width: 48, height: 48)
            VStack(alignment: .leading, spacing: 4) {
                Text(file.name)
                    .font(.subheadline.weight(.semibold))
                HStack(spacing: 8) {
                    if file.kind == .folder {
                        HStack(spacing: 4) {
                            Image(systemName: "icloud.fill")
                                .font(.caption2)
                            Text("Synced folder")
                                .font(.caption)
                        }
                        .foregroundStyle(Theme.Suite.cloudBlue)
                    } else {
                        Text(file.owner)
                            .font(.caption)
                            .foregroundStyle(Theme.color.textSecondary)
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(Theme.color.textSecondary)
                        Text(file.size)
                            .font(.caption)
                            .foregroundStyle(Theme.color.textSecondary)
                    }
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                Image(systemName: "icloud.fill")
                    .font(.caption)
                    .foregroundStyle(Theme.Suite.lineConnected.opacity(0.9))
                Text(file.modified)
                    .font(.caption2)
                    .foregroundStyle(Theme.color.textSecondary)
            }
        }
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {} label: { Label("Delete", systemImage: "trash") }
            Button {} label: { Label("Star", systemImage: "star.fill") }.tint(.yellow)
            Button {} label: { Label("Share", systemImage: "square.and.arrow.up") }.tint(Theme.Suite.cloudBlue)
        }
    }

    private func gridCell(for file: DriveFile) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Theme.Suite.elevatedSurface)
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Theme.Suite.separator.opacity(0.6), lineWidth: 1)
                Image(systemName: file.icon)
                    .font(.system(size: 36))
                    .foregroundStyle(folderAccent(for: file))
            }
            .frame(height: 100)
            Text(file.name)
                .font(.caption.weight(.semibold))
                .lineLimit(2)
            HStack {
                Text(file.kind == .folder ? "Folder" : file.size)
                    .font(.caption2)
                    .foregroundStyle(Theme.color.textSecondary)
                Spacer()
                Image(systemName: "icloud.and.arrow.down")
                    .font(.caption2)
                    .foregroundStyle(Theme.Suite.cloudBlue.opacity(0.8))
            }
        }
        .padding(10)
    }
}

#Preview {
    NavigationStack { DriveView().environmentObject(AppState()) }
}
