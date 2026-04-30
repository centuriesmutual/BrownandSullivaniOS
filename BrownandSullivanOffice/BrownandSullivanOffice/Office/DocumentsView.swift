import SwiftUI

/// Policy and carrier document hub (office documents area).
struct DocumentsView: View {
    @EnvironmentObject private var app: AppState
    @State private var query = ""

    private var filtered: [OfficeDocumentItem] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return app.officeDocuments }
        return app.officeDocuments.filter {
            $0.name.lowercased().contains(q)
                || $0.category.lowercased().contains(q)
                || $0.owner.lowercased().contains(q)
        }
    }

    var body: some View {
        List {
            Section {
                CloudSyncStatusRow(isSynced: true, subtitle: "Policy library")
                    .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
            Section {
                ForEach(filtered) { doc in
                    HStack(alignment: .top, spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Theme.Suite.cloudBlueSoft.opacity(0.7))
                            Image(systemName: "doc.text.fill")
                                .font(.title3)
                                .foregroundStyle(Theme.Suite.cloudBlue)
                        }
                        .frame(width: 44, height: 44)
                        VStack(alignment: .leading, spacing: 6) {
                            Text(doc.name)
                                .font(.subheadline.weight(.semibold))
                            HStack(spacing: 8) {
                                ChipBadge(text: doc.category, color: Theme.Suite.cloudBlue)
                                Text(doc.status)
                                    .font(.caption2.weight(.medium))
                                    .foregroundStyle(Theme.color.textSecondary)
                            }
                            HStack {
                                Text("Owner: \(doc.owner)")
                                Spacer()
                                Text(doc.updated)
                            }
                            .font(.caption)
                            .foregroundStyle(Theme.color.textSecondary)
                        }
                    }
                    .padding(.vertical, 6)
                }
            } header: {
                Text("Library")
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .suiteGroupedBackground()
        .searchable(text: $query, prompt: "Search documents")
    }
}

#Preview {
    NavigationStack {
        DocumentsView().environmentObject(AppState())
    }
}
