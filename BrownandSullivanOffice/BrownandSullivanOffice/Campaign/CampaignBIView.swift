import SwiftUI

/// Simplified `app/bi/page.tsx` — weekly engagement strip.
struct CampaignBIView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Engagement by day").font(.headline)
                let pts = app.biWeekEngagement
                let maxE = Double(pts.map(\.engagement).max() ?? 1)
                GeometryReader { geo in
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(pts) { p in
                            VStack {
                                Text("\(p.engagement)%")
                                    .font(.caption2)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(PressBoxTheme.indigo)
                                    .frame(width: 28, height: max(8, CGFloat(Double(p.engagement) / maxE) * (geo.size.height - 28)))
                                Text(p.day)
                                    .font(.caption2)
                                    .foregroundStyle(PressBoxTheme.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                }
                .frame(height: 200)
                .padding()
                .pressBoxCard()

                Text("Views trend").font(.headline)
                VStack(spacing: 10) {
                    let cap = Double(pts.map(\.views).max() ?? 1)
                    ForEach(pts) { p in
                        HStack {
                            Text(p.day).frame(width: 40, alignment: .leading)
                            ProgressView(value: Double(p.views), total: cap)
                            Text(p.views.formatted())
                                .font(.caption.monospacedDigit())
                        }
                    }
                }
                .padding()
                .pressBoxCard()
            }
            .padding(16)
        }
        .background(PressBoxTheme.background)
        .navigationTitle("Advanced BI")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") { dismiss() }
            }
        }
    }
}

#Preview {
    CampaignBIView().environmentObject(AppState())
}
