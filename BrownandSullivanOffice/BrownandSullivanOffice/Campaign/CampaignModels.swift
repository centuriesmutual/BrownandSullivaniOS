import Foundation
import SwiftUI

// MARK: - Events (matches `data/events.json` + dashboard)

enum PressEventKind: String, CaseIterable, Hashable {
    case meeting, review, event

    var icon: String { "calendar" }

    var tint: Color {
        switch self {
        case .meeting: Color(hex: 0x9333EA)
        case .review: Color(hex: 0x2563EB)
        case .event: Color(hex: 0x16A34A)
        }
    }
}

struct PressEvent: Identifiable, Hashable {
    let id: Int
    var title: String
    var time: String
    /// `YYYY-MM-DD`
    var date: String
    var type: PressEventKind
}

// MARK: - Tasks

struct MarketingTaskItem: Identifiable, Hashable {
    let id: Int
    let title: String
    let description: String
    let dueDate: String
    let priority: String
    var status: String
    let assignedBy: String
}

// MARK: - Messaging (Campaign hub)

enum CampaignPresence: String, Hashable {
    case online, away, offline
}

struct CampaignInboxPerson: Identifiable, Hashable {
    let id: Int
    let name: String
    let role: String
    var lastMessage: String
    var timestamp: String
    var unread: Int
    let presence: CampaignPresence
    let initials: String
}

struct CampaignThreadMessage: Identifiable, Hashable {
    let id: Int
    let sender: String
    let content: String
    let timestamp: String
    let isOwn: Bool
}

// MARK: - Account balance

struct CampaignAccountSnapshot: Hashable {
    var currentBalance: Decimal
    var previousBalance: Decimal
    var totalEarnings: Decimal
    var totalSpent: Decimal
    var pendingAmount: Decimal
}

struct CampaignTransaction: Identifiable, Hashable {
    let id: Int
    let isCredit: Bool
    let amount: Decimal
    let description: String
    let date: String
    let status: String
}

// MARK: - Intelligence (article analytics)

struct IntelligenceArticle: Identifiable, Hashable {
    let id: Int
    let title: String
    let views: Int
    let engagement: Int
    let publishDate: String
    let status: String
    let category: String
}

// MARK: - Performance charts

struct PerformanceDayRow: Identifiable, Hashable {
    let id: Int
    let label: String
    let spend: Double
    let revenue: Double
    let roas: Double
}

struct NamedCampaignSummary: Identifiable, Hashable {
    let id: Int
    let name: String
    let spend: Double
    let revenue: Double
    let roas: Double
}

// MARK: - Advanced BI sample

struct BIDayPoint: Identifiable, Hashable {
    let id: Int
    let day: String
    let engagement: Int
    let views: Int
}

// MARK: - Tabs (matches dashboard `layout.tsx`)

enum CampaignTab: String, CaseIterable, Identifiable {
    case dashboard
    case messaging
    case submissions
    case intelligence

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard: "Dashboard"
        case .messaging: "Messaging"
        case .submissions: "Submissions"
        case .intelligence: "Intelligence"
        }
    }

    var shortTitle: String {
        switch self {
        case .dashboard: "Home"
        case .messaging: "Chat"
        case .submissions: "Submit"
        case .intelligence: "Intel"
        }
    }

    var icon: String {
        switch self {
        case .dashboard: "house.fill"
        case .messaging: "bubble.left.and.bubble.right.fill"
        case .submissions: "doc.text.fill"
        case .intelligence: "chart.bar.fill"
        }
    }
}

// MARK: - Helpers

enum CampaignDateFormat {
    static func displayLabel(yyyyMMdd: String) -> String {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone.current
        f.dateFormat = "yyyy-MM-dd"
        guard let d = f.date(from: yyyyMMdd) else { return yyyyMMdd }
        let cal = Calendar.current
        if cal.isDateInToday(d) { return "Today" }
        if cal.isDateInTomorrow(d) { return "Tomorrow" }
        let out = DateFormatter()
        out.dateStyle = .medium
        out.timeStyle = .none
        return out.string(from: d)
    }

    static func storageString(from date: Date) -> String {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone.current
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}
