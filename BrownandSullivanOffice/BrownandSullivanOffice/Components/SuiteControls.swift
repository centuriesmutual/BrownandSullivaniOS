import SwiftUI

/// Google / Apple workspace–style omnibox search.
struct SuiteSearchBar: View {
    @Binding var text: String
    var prompt: String = "Search mail, files, people…"

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.body.weight(.medium))
                .foregroundStyle(Theme.color.textSecondary)
            TextField(prompt, text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Theme.color.textSecondary.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Theme.Suite.elevatedSurface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Theme.color.border.opacity(0.6), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

/// Dropbox-style sync / online status strip.
struct CloudSyncStatusRow: View {
    var isSynced: Bool = true
    var subtitle: String = "Just now"

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isSynced ? "checkmark.icloud.fill" : "icloud.and.arrow.down")
                .font(.title3)
                .foregroundStyle(isSynced ? Theme.Suite.cloudBlue : Theme.color.warning)
            VStack(alignment: .leading, spacing: 2) {
                Text(isSynced ? "All files synced" : "Syncing…")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.color.textPrimary)
                Text(isSynced ? "Cloud storage · \(subtitle)" : "Downloading changes")
                    .font(.caption)
                    .foregroundStyle(Theme.color.textSecondary)
            }
            Spacer()
            if isSynced {
                Image(systemName: "wifi")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.color.textSecondary)
            }
        }
        .padding(14)
        .background(Theme.Suite.cloudBlueSoft.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Theme.Suite.cloudBlue.opacity(0.12), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        SuiteSearchBar(text: .constant(""))
        CloudSyncStatusRow()
    }
    .padding()
    .suiteGroupedBackground()
}
