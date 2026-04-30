import SwiftUI

/// One of the rounded-square icons in the iOS-style "app grid" on the home
/// dashboard.
struct IOSAppIcon: View {
    let title: String
    let icon: String
    let gradient: [Color]
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(LinearGradient(colors: gradient,
                                             startPoint: .topLeading,
                                             endPoint: .bottomTrailing))
                        .frame(width: 64, height: 64)
                        .shadow(color: (gradient.last ?? .clear).opacity(0.28), radius: 6, y: 3)
                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                }
                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Theme.color.textPrimary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
