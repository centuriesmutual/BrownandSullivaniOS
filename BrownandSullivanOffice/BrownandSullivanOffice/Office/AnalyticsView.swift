import SwiftUI

struct AnalyticsView: View {
    @EnvironmentObject private var app: AppState
    @State private var range: Range = .week

    enum Range: String, CaseIterable, Identifiable {
        case day = "Today", week = "Week", month = "Month", quarter = "Quarter"
        var id: String { rawValue }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing.l) {
                rangePicker
                statsGrid
                performanceCard
                salesTableCard
                callMixCard
            }
            .padding(Theme.spacing.l)
        }
    }

    private var rangePicker: some View {
        Picker("Range", selection: $range) {
            ForEach(Range.allCases) { Text($0.rawValue).tag($0) }
        }
        .pickerStyle(.segmented)
    }

    private var statsGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2),
                  spacing: 12) {
            ForEach(app.stats) { stat in
                StatCard(metric: stat)
            }
        }
    }

    private var performanceCard: some View {
        TitledCard("Performance", icon: "chart.line.uptrend.xyaxis") {
            VStack(spacing: 14) {
                ForEach([("Calls answered", 0.82, Theme.color.success),
                         ("Calls abandoned", 0.08, Theme.color.danger),
                         ("Avg handle time", 0.55, Theme.color.info),
                         ("First-call resolution", 0.71, Theme.color.primary)],
                        id: \.0) { row in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(row.0).font(.subheadline)
                            Spacer()
                            Text("\(Int(row.1 * 100))%")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(row.2)
                        }
                        progressBar(value: row.1, color: row.2)
                    }
                }
            }
        }
    }

    private func progressBar(value: Double, color: Color) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4).fill(Theme.color.border.opacity(0.5))
                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .frame(width: max(0, geo.size.width * value))
            }
        }
        .frame(height: 8)
    }

    private var salesTableCard: some View {
        TitledCard("Recent sales", icon: "dollarsign.circle.fill") {
            VStack(spacing: 0) {
                tableHeader
                Divider()
                ForEach(Array(app.sales.enumerated()), id: \.element.id) { idx, sale in
                    HStack {
                        Text(sale.agent).font(.caption)
                        Spacer()
                        Text(sale.plan).font(.caption).foregroundStyle(Theme.color.textSecondary)
                        Spacer()
                        Text(sale.premium).font(.caption.monospacedDigit())
                        Spacer()
                        ChipBadge(text: sale.status, color: statusColor(sale.status))
                    }
                    .padding(.vertical, 8)
                    if idx < app.sales.count - 1 { Divider() }
                }
            }
        }
    }

    private var tableHeader: some View {
        HStack {
            Text("Agent")
            Spacer()
            Text("Plan")
            Spacer()
            Text("Premium")
            Spacer()
            Text("Status")
        }
        .font(.caption2.weight(.bold))
        .textCase(.uppercase)
        .foregroundStyle(Theme.color.textSecondary)
        .padding(.bottom, 6)
    }

    private func statusColor(_ s: String) -> Color {
        switch s {
        case "Approved": Theme.color.success
        case "Pending":  Theme.color.warning
        case "Declined": Theme.color.danger
        default:         Theme.color.secondary
        }
    }

    private var callMixCard: some View {
        TitledCard("Call mix", icon: "chart.pie.fill") {
            HStack(spacing: 16) {
                PieChart(slices: [
                    .init(value: 42, color: Theme.color.primary, label: "Inbound"),
                    .init(value: 28, color: Theme.color.info,    label: "Outbound"),
                    .init(value: 18, color: Theme.color.success, label: "Callbacks"),
                    .init(value: 12, color: Theme.color.warning, label: "Voicemails")
                ])
                .frame(width: 120, height: 120)

                VStack(alignment: .leading, spacing: 6) {
                    legendRow("Inbound",    Theme.color.primary, "42%")
                    legendRow("Outbound",   Theme.color.info,    "28%")
                    legendRow("Callbacks",  Theme.color.success, "18%")
                    legendRow("Voicemails", Theme.color.warning, "12%")
                }
                Spacer()
            }
            .padding(.vertical, 6)
        }
    }

    private func legendRow(_ name: String, _ color: Color, _ pct: String) -> some View {
        HStack {
            Circle().fill(color).frame(width: 10, height: 10)
            Text(name).font(.caption)
            Spacer()
            Text(pct).font(.caption.weight(.semibold))
        }
    }
}

// MARK: - Pie chart (lightweight, no Charts framework dependency)

private struct PieSlice: Identifiable {
    let id = UUID()
    let value: Double
    let color: Color
    let label: String
}

private struct PieChart: View {
    let slices: [PieSlice]

    var body: some View {
        Canvas { ctx, size in
            let total = slices.reduce(0) { $0 + $1.value }
            guard total > 0 else { return }
            let rect = CGRect(origin: .zero, size: size)
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = min(rect.width, rect.height) / 2
            var start = Angle.degrees(-90)
            for slice in slices {
                let sweep = Angle.degrees(slice.value / total * 360)
                let path = Path { p in
                    p.move(to: center)
                    p.addArc(center: center, radius: radius,
                             startAngle: start, endAngle: start + sweep,
                             clockwise: false)
                    p.closeSubpath()
                }
                ctx.fill(path, with: .color(slice.color))
                start += sweep
            }
            // donut hole
            let inner = Path(ellipseIn: CGRect(
                x: center.x - radius * 0.55,
                y: center.y - radius * 0.55,
                width: radius * 1.10,
                height: radius * 1.10
            ))
            ctx.fill(inner, with: .color(Theme.color.cardBackground))
        }
    }
}

#Preview {
    NavigationStack { AnalyticsView().environmentObject(AppState()) }
}
