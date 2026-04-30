import SwiftUI

/// Article intelligence — mirrors `dashboard/settings/page.tsx` (History / BI table).
struct CampaignIntelligenceView: View {
    @EnvironmentObject private var app: AppState
    @State private var sortKey: Sort = .views
    @State private var ascending = false

    enum Sort: String, CaseIterable, Identifiable {
        case views = "Views"
        case engagement = "Engagement"
        case date = "Date"
        case title = "Title"
        var id: String { rawValue }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if app.campaignExperienceTier == .popular {
                    popularIntelligenceBanner
                }
                HStack {
                    Picker("Sort", selection: $sortKey) {
                        ForEach(Sort.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.menu)
                    Button {
                        ascending.toggle()
                    } label: {
                        Image(systemName: ascending ? "arrow.up" : "arrow.down")
                    }
                }
                ForEach(sortedArticles) { a in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(a.title).font(.headline)
                        HStack {
                            Label("\(a.views.formatted()) views", systemImage: "eye")
                            Label("\(a.engagement)%", systemImage: "chart.line.uptrend.xyaxis")
                        }
                        .font(.caption)
                        .foregroundStyle(PressBoxTheme.textSecondary)
                        HStack {
                            Text(a.category).font(.caption2).padding(6)
                                .background(PressBoxTheme.indigoLight)
                                .foregroundStyle(PressBoxTheme.indigoDark)
                                .clipShape(Capsule())
                            Text(a.publishDate).font(.caption2).foregroundStyle(PressBoxTheme.textSecondary)
                            Spacer()
                            Text(a.status)
                                .font(.caption2.weight(.semibold))
                                .padding(.horizontal, 8).padding(.vertical, 4)
                                .background(PressBoxTheme.chip(for: a.status).0)
                                .foregroundStyle(PressBoxTheme.chip(for: a.status).1)
                                .clipShape(Capsule())
                        }
                    }
                    .padding()
                    .pressBoxCard()
                }
            }
            .padding(16)
        }
        .background(PressBoxTheme.background)
    }

    private var popularIntelligenceBanner: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles.rectangle.stack.fill")
                    .foregroundStyle(PressBoxTheme.indigo)
                Text("Popular workspace")
                    .font(.headline)
                Spacer()
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
            }
            Text("Top-performing content across your org — same order your stakeholders see in the web hub.")
                .font(.caption)
                .foregroundStyle(PressBoxTheme.textSecondary)
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(app.trendingIntelligenceArticles.prefix(3))) { a in
                    HStack {
                        Text(a.title)
                            .font(.subheadline.weight(.medium))
                            .lineLimit(1)
                        Spacer()
                        Text("\(a.views.formatted()) views")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(PressBoxTheme.indigo)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(PressBoxTheme.indigo.opacity(0.15), lineWidth: 1)
        )
    }

    private var sortedArticles: [IntelligenceArticle] {
        let base = app.intelligenceArticles
        switch sortKey {
        case .views:
            return base.sorted { ascending ? $0.views < $1.views : $0.views > $1.views }
        case .engagement:
            return base.sorted { ascending ? $0.engagement < $1.engagement : $0.engagement > $1.engagement }
        case .date:
            return base.sorted { ascending ? $0.publishDate < $1.publishDate : $0.publishDate > $1.publishDate }
        case .title:
            return base.sorted { ascending ? $0.title < $1.title : $0.title > $1.title }
        }
    }
}

#Preview {
    CampaignIntelligenceView().environmentObject(AppState())
}
