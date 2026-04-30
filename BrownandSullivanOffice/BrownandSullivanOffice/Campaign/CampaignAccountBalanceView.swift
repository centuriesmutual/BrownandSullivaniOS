import SwiftUI

/// `dashboard/account-balance/page.tsx`
struct CampaignAccountBalanceView: View {
    @EnvironmentObject private var app: AppState
    @State private var showBalance = true
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                metricsRow
                transactionsCard
            }
            .padding(16)
        }
        .background(PressBoxTheme.background)
        .navigationTitle("Account Balance")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Close") { dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showBalance.toggle()
                } label: {
                    Image(systemName: showBalance ? "eye.slash" : "eye")
                }
            }
        }
    }

    private var metricsRow: some View {
        let snap = app.accountSnapshot
        let change = snap.currentBalance - snap.previousBalance
        let prev = snap.previousBalance
        let pct: Double = {
            let p = (prev as NSDecimalNumber).doubleValue
            guard p != 0 else { return 0 }
            let c = (change as NSDecimalNumber).doubleValue
            return (c / p) * 100
        }()
        return VStack(spacing: 12) {
            bigMetric(
                title: "Current balance",
                value: money(snap.currentBalance, hidden: !showBalance),
                foot: showBalance
                    ? "\((change as NSDecimalNumber).doubleValue >= 0 ? "+" : "")\(money(absDecimal(change), hidden: false)) (\(String(format: "%.1f", pct))%)"
                    : "••••"
            )
            HStack(spacing: 12) {
                smallMetric("Earnings", money(snap.totalEarnings, hidden: !showBalance))
                smallMetric("Spent", money(snap.totalSpent, hidden: !showBalance))
                smallMetric("Pending", money(snap.pendingAmount, hidden: !showBalance))
            }
        }
    }

    private func absDecimal(_ d: Decimal) -> Decimal {
        (d as NSDecimalNumber).doubleValue < 0 ? -d : d
    }

    private func bigMetric(title: String, value: String, foot: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(PressBoxTheme.textSecondary)
            Text(value).font(.title.bold())
            Text(foot).font(.subheadline).foregroundStyle(PressBoxTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .pressBoxCard()
    }

    private func smallMetric(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption).foregroundStyle(PressBoxTheme.textSecondary)
            Text(value).font(.subheadline.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .pressBoxCard()
    }

    private var transactionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent transactions").font(.headline)
            ForEach(app.campaignTransactions) { tx in
                HStack {
                    Image(systemName: tx.isCredit ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                        .foregroundStyle(tx.isCredit ? Color(hex: 0x16A34A) : Color(hex: 0xDC2626))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(tx.description).font(.subheadline)
                        Text(tx.date).font(.caption2).foregroundStyle(PressBoxTheme.textSecondary)
                    }
                    Spacer()
                    Text(money(tx.amount, hidden: !showBalance))
                        .font(.subheadline.monospacedDigit().weight(.semibold))
                        .foregroundStyle(tx.isCredit ? Color(hex: 0x16A34A) : PressBoxTheme.textPrimary)
                }
                .padding(.vertical, 6)
                Divider()
            }
        }
        .padding()
        .pressBoxCard()
    }

    private func money(_ d: Decimal, hidden: Bool) -> String {
        if hidden { return "••••••" }
        let n = NSDecimalNumber(decimal: d)
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "USD"
        return f.string(from: n) ?? "$0.00"
    }
}

#Preview {
    CampaignAccountBalanceView().environmentObject(AppState())
}
