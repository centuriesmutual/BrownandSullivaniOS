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
                ForEach(filtered) { doc in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "doc.text.fill")
                            .font(.title2)
                            .foregroundStyle(Theme.color.info)
                            .frame(width: 36, height: 36)
                            .background(Theme.color.info.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        VStack(alignment: .leading, spacing: 6) {
                            Text(doc.name)
                                .font(.subheadline.weight(.semibold))
                            HStack(spacing: 8) {
                                ChipBadge(text: doc.category, color: Theme.color.primary)
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
                    .padding(.vertical, 4)
                }
            } header: {
                Text("Library")
            }
        }
        .listStyle(.insetGrouped)
        .searchable(text: $query, prompt: "Search documents")
        .background(Theme.color.background.ignoresSafeArea())
    }
}

#Preview {
    NavigationStack {
        DocumentsView().environmentObject(AppState())
    }
}
