import SwiftUI

/// Trending strip for **Popular** campaign tier — horizontal discovery of top articles & campaigns.
struct CampaignPopularHighlightsStrip: View {
    @EnvironmentObject private var app: AppState

    private var topArticles: [IntelligenceArticle] {
        Array(app.trendingIntelligenceArticles.prefix(8))
    }

    private var topCampaigns: [NamedCampaignSummary] {
        Array(app.trendingCampaignSummaries.prefix(4))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Popular now", systemImage: "flame.fill")
                    .font(.headline)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: 0xEA580C), Color(hex: 0xF97316)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Spacer()
                Text("Trending for your role")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(PressBoxTheme.textSecondary)
            }
            .padding(.horizontal, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(topArticles) { article in
                        articleCard(article)
                    }
                    ForEach(topCampaigns) { campaign in
                        campaignCard(campaign)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
            }
        }
        .padding(.vertical, 14)
        .background(
            LinearGradient(
                colors: [PressBoxTheme.indigoLight.opacity(0.95), Color.white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(PressBoxTheme.indigo.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: PressBoxTheme.indigo.opacity(0.08), radius: 14, x: 0, y: 6)
        .padding(.horizontal, 16)
    }

    private func articleCard(_ article: IntelligenceArticle) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(article.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(PressBoxTheme.textPrimary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            HStack(spacing: 10) {
                Label(article.views.formatted(), systemImage: "eye.fill")
                Label("\(article.engagement)%", systemImage: "heart.fill")
            }
            .font(.caption2.weight(.medium))
            .foregroundStyle(PressBoxTheme.indigo)
            Text(article.category)
                .font(.caption2.weight(.bold))
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(PressBoxTheme.indigoLight)
                .foregroundStyle(PressBoxTheme.indigoDark)
                .clipShape(Capsule())
        }
        .padding(14)
        .frame(width: 220, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(PressBoxTheme.border, lineWidth: 1)
        )
    }

    private func campaignCard(_ campaign: NamedCampaignSummary) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Top ROAS pick", systemImage: "chart.line.uptrend.xyaxis")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color(hex: 0x047857))
            Text(campaign.name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(PressBoxTheme.textPrimary)
                .lineLimit(2)
            Text("ROAS \(Int(campaign.roas))%")
                .font(.title3.weight(.bold))
                .foregroundStyle(PressBoxTheme.indigo)
        }
        .padding(14)
        .frame(width: 180, alignment: .leading)
        .background(Color(hex: 0xECFDF5))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color(hex: 0xA7F3D0), lineWidth: 1)
        )
    }
}

#Preview {
    ScrollView {
        CampaignPopularHighlightsStrip()
    }
    .environmentObject(AppState())
}
