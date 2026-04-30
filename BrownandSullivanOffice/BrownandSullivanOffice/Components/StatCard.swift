import SwiftUI

struct StatCard: View {
    let metric: StatMetric

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.s) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(metric.color.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: metric.icon)
                        .foregroundStyle(metric.color)
                        .font(.headline)
                }
                Spacer()
                Text(metric.delta)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background((metric.positive ? Theme.color.success : Theme.color.danger).opacity(0.12))
                    .foregroundStyle(metric.positive ? Theme.color.success : Theme.color.danger)
                    .clipShape(Capsule())
            }
            Text(metric.value)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Theme.color.textPrimary)
            Text(metric.title)
                .font(.caption)
                .foregroundStyle(Theme.color.textSecondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .dashboardCardStyle()
    }
}
