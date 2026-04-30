import SwiftUI

/// The white rounded "card" with a gradient header used everywhere on the
/// dashboard. Mirrors `.dashboard-card` from the original web app's CSS.
struct DashboardCard<Header: View, Content: View>: View {
    let header: Header
    let content: Content

    init(@ViewBuilder header: () -> Header, @ViewBuilder content: () -> Content) {
        self.header = header()
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                header
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.gradient.cardHeader)
            .overlay(Rectangle().fill(Theme.color.border).frame(height: 1), alignment: .bottom)

            VStack(alignment: .leading, spacing: Theme.spacing.m) {
                content
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .dashboardCardStyle()
    }
}

/// Convenience: a dashboard card with a title + SF Symbol header.
struct TitledCard<Content: View>: View {
    let title: String
    let icon: String
    var trailing: AnyView?
    @ViewBuilder var content: () -> Content

    init(_ title: String, icon: String, trailing: AnyView? = nil,
         @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.icon = icon
        self.trailing = trailing
        self.content = content
    }

    var body: some View {
        DashboardCard {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(Theme.color.primary)
                    .font(.headline)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Theme.color.primary)
                Spacer()
                if let trailing { trailing }
            }
        } content: {
            content()
        }
    }
}
