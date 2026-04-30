import SwiftUI

/// Simplified `dashboard/performance/page.tsx` — time series + campaign table.
struct CampaignPerformanceView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Spend vs revenue (sample)")
                    .font(.headline)
                chart
                Text("Campaigns")
                    .font(.headline)
                ForEach(app.campaignSummaries) { c in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(c.name).font(.subheadline.weight(.semibold))
                        HStack {
                            metric("Spend", c.spend)
                            metric("Revenue", c.revenue)
                            metric("ROAS", c.roas, suffix: "%")
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .pressBoxCard()
                }
            }
            .padding(16)
        }
        .background(PressBoxTheme.background)
        .navigationTitle("Performance")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") { dismiss() }
            }
        }
    }

    private func metric(_ label: String, _ value: Double, suffix: String = "") -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.caption2).foregroundStyle(PressBoxTheme.textSecondary)
            Text(suffix.isEmpty ? value.formatted(.number.grouping(.automatic)) : "\(Int(value))" + suffix)
                .font(.caption.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var chart: some View {
        let rows = app.performanceDays
        let maxR = rows.map(\.revenue).max() ?? 1
        return VStack(alignment: .leading, spacing: 8) {
            GeometryReader { geo in
                let w = geo.size.width
                let barW = max(4, (w - CGFloat(rows.count) * 2) / CGFloat(max(rows.count, 1)))
                HStack(alignment: .bottom, spacing: 2) {
                    ForEach(rows) { row in
                        let h = CGFloat(row.revenue / maxR) * geo.size.height * 0.85
                        RoundedRectangle(cornerRadius: 2)
                            .fill(PressBoxTheme.indigo.opacity(0.85))
                            .frame(width: barW, height: max(4, h))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
            .frame(height: 160)
            .padding(8)
            .background(PressBoxTheme.background)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .pressBoxCard()
    }
}

#Preview {
    CampaignPerformanceView().environmentObject(AppState())
}
