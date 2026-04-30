import Foundation
import SwiftUI
import Combine

/// Top-level navigation: workspace hub, each product’s login, and shells.
enum AppRoot: Equatable {
    case hub
    case officeLogin
    case office
    case officeAdmin
    case campaignLogin
    case campaign
}

/// Single source of truth for the app. Mirrors the seeded fixtures from the
/// original Next.js app's `app/office/page.js` and `app/admin/page.js`.
@MainActor
final class AppState: ObservableObject {

    // MARK: - Routing
    @Published var activeRoot: AppRoot = .hub
    @Published var officeTab: OfficeTab = .home
    @Published var campaignTab: CampaignTab = .dashboard

    // MARK: - Session
    @Published var userName: String = "Alex Morgan"
    @Published var userEmail: String = "alex.morgan@brownandsullivan.com"
    @Published var userInitials: String = "AM"
    @Published var disposition: AgentDisposition = .active

    @Published var isTimedIn: Bool = false
    @Published var totalSecondsToday: Int = 0

    // MARK: - Inbox
    @Published var emails: [EmailMessage] = AppState.seedEmails
    @Published var emailFolder: EmailFolder = .inbox

    // MARK: - Calendar
    @Published var events: [CalendarEvent] = AppState.seedEvents

    // MARK: - Meetings
    @Published var meetings: [Meeting] = AppState.seedMeetings

    // MARK: - Notes / client history
    @Published var notes: [ClientNote] = AppState.seedNotes

    // MARK: - Drive
    @Published var driveFiles: [DriveFile] = AppState.seedDrive

    // MARK: - Chat
    @Published var chatContacts: [ChatContact] = AppState.seedContacts
    @Published var chatThreads: [UUID: [ChatMessage]] = [:]

    // MARK: - Recent calls
    @Published var recentCalls: [ClientCall] = AppState.seedCalls

    // MARK: - Activity
    @Published var activity: [ActivityItem] = AppState.seedActivity

    // MARK: - Analytics
    @Published var stats: [StatMetric] = AppState.seedStats
    @Published var sales: [SaleRow] = AppState.seedSales

    // MARK: - Admin
    @Published var systemStatus: [SystemComponentStatus] = AppState.seedSystemStatus
    @Published var adminUsers: [AdminUser] = AppState.seedAdminUsers
    @Published var adminActivity: [AdminActivity] = AppState.seedAdminActivity
    @Published var systemMetrics: SystemMetrics = .init(cpu: 45, memory: 62, disk: 58, network: 32)
    @Published var userStats: UserStats = .init(total: 1250, active: 856, newToday: 45, premium: 320)

    // MARK: - AI Assistant
    @Published var aiMessages: [AIChatMessage] = [
        AIChatMessage(role: .assistant, body: "Hi Alex — I'm your office assistant. Ask me to draft an email, summarize a meeting, or pull up a client.")
    ]

    // MARK: - Office shortcuts (the iOS-style app grid on the home dashboard)

    // MARK: - PressBox / Campaign (Marketing Hub)
    @Published var campaignUserName: String = "Jordan Lee"
    @Published var campaignUserEmail: String = "jordan.lee@pressbox.marketing"
    @Published var campaignEvents: [PressEvent] = AppState.seedPressEvents
    @Published var marketingTasks: [MarketingTaskItem] = AppState.seedMarketingTasks
    @Published var campaignInbox: [CampaignInboxPerson] = AppState.seedCampaignInbox
    @Published var campaignThreads: [Int: [CampaignThreadMessage]] = AppState.seedCampaignThreads
    @Published var accountSnapshot: CampaignAccountSnapshot = AppState.seedAccountSnapshot
    @Published var campaignTransactions: [CampaignTransaction] = AppState.seedCampaignTransactions
    @Published var intelligenceArticles: [IntelligenceArticle] = AppState.seedIntelligenceArticles
    @Published var performanceDays: [PerformanceDayRow] = AppState.seedPerformanceDays
    @Published var campaignSummaries: [NamedCampaignSummary] = AppState.seedCampaignSummaries
    @Published var biWeekEngagement: [BIDayPoint] = AppState.seedBIWeek

    @Published var shortcuts: [OfficeAppShortcut] = [
        .init(title: "Phone",     icon: "phone.fill",      gradient: [Color(hex: 0x22C55E), Color(hex: 0x16A34A)], destinationTab: .dialer),
        .init(title: "Mail",      icon: "envelope.fill",   gradient: [Color(hex: 0x3B82F6), Color(hex: 0x2563EB)], destinationTab: .email),
        .init(title: "Calendar",  icon: "calendar",        gradient: [Color(hex: 0xEF4444), Color(hex: 0xDC2626)], destinationTab: .calendar),
        .init(title: "Drive",     icon: "folder.fill",     gradient: [Color(hex: 0xF59E0B), Color(hex: 0xD97706)], destinationTab: .drive),
        .init(title: "Chat",      icon: "message.fill",    gradient: [Color(hex: 0x8B5CF6), Color(hex: 0x7C3AED)], destinationTab: .chat),
        .init(title: "Analytics", icon: "chart.bar.fill",  gradient: [Color(hex: 0x0EA5E9), Color(hex: 0x0284C7)], destinationTab: .analytics),
        .init(title: "Settings",  icon: "gearshape.fill",  gradient: [Color(hex: 0x64748B), Color(hex: 0x475569)], destinationTab: .settings),
        .init(title: "Meet",      icon: "video.fill",      gradient: [Color(hex: 0x10B981), Color(hex: 0x059669)], destinationTab: .calendar),
    ]

    // MARK: - Auth-ish actions

    func signIn(email: String, password: String) -> Bool {
        guard !email.isEmpty, !password.isEmpty else { return false }
        userEmail = email
        userName = email.split(separator: "@").first.map(String.init) ?? email
        userInitials = String(email.prefix(2)).uppercased()
        activeRoot = .office
        officeTab = .home
        return true
    }

    func signInCampaign(email: String, password: String) -> Bool {
        guard !email.isEmpty, !password.isEmpty else { return false }
        campaignUserEmail = email
        campaignUserName = email.split(separator: "@").first.map { capLocalPart(String($0)) } ?? email
        activeRoot = .campaign
        campaignTab = .dashboard
        return true
    }

    func signOut() {
        activeRoot = .hub
    }

    func goToHub() {
        activeRoot = .hub
    }

    func goToOfficeLogin() {
        activeRoot = .officeLogin
    }

    func goToCampaignLogin() {
        activeRoot = .campaignLogin
    }

    func switchToAdmin() {
        activeRoot = .officeAdmin
    }

    func backToOffice() {
        activeRoot = .office
    }

    // MARK: - Campaign messaging

    func campaignMessages(for conversationId: Int) -> [CampaignThreadMessage] {
        campaignThreads[conversationId] ?? []
    }

    func sendCampaignMessage(conversationId: Int, text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var thread = campaignMessages(for: conversationId)
        let nextId = (thread.map(\.id).max() ?? 0) + 1
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        thread.append(CampaignThreadMessage(
            id: nextId,
            sender: "You",
            content: trimmed,
            timestamp: f.string(from: Date()),
            isOwn: true
        ))
        campaignThreads[conversationId] = thread
        if let idx = campaignInbox.firstIndex(where: { $0.id == conversationId }) {
            campaignInbox[idx].lastMessage = trimmed
            campaignInbox[idx].timestamp = "Just now"
            campaignInbox[idx].unread = 0
        }
    }

    func addCampaignEvent(title: String, time: String, on date: Date, type: PressEventKind) {
        let nextId = (campaignEvents.map(\.id).max() ?? 0) + 1
        let row = PressEvent(
            id: nextId,
            title: title,
            time: time,
            date: CampaignDateFormat.storageString(from: date),
            type: type
        )
        campaignEvents.append(row)
    }

    private static func capLocalPart(_ s: String) -> String {
        s.split(separator: ".").map { $0.capitalized }.joined(separator: " ")
    }

    // MARK: - Email actions

    var visibleEmails: [EmailMessage] {
        switch emailFolder {
        case .inbox: emails
        case .starred: emails.filter(\.starred)
        case .sent: []
        case .drafts: []
        case .trash: []
        }
    }

    func toggleStar(_ email: EmailMessage) {
        guard let i = emails.firstIndex(where: { $0.id == email.id }) else { return }
        emails[i].starred.toggle()
    }

    func markRead(_ email: EmailMessage) {
        guard let i = emails.firstIndex(where: { $0.id == email.id }) else { return }
        emails[i].unread = false
    }

    var unreadCount: Int { emails.filter(\.unread).count }

    // MARK: - AI

    func sendToAssistant(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        aiMessages.append(AIChatMessage(role: .user, body: trimmed))
        // Toy reply
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 500_000_000)
            self?.aiMessages.append(
                AIChatMessage(role: .assistant,
                              body: "Got it — I'll look into \"\(trimmed)\" and circle back.")
            )
        }
    }

    // MARK: - Chat

    func messages(for contact: ChatContact) -> [ChatMessage] {
        if let m = chatThreads[contact.id] { return m }
        let seed: [ChatMessage] = [
            .init(body: "Hi! How's it going?", timestamp: "10:14 AM", isMine: false),
            .init(body: "Doing well, just wrapping up the call notes.", timestamp: "10:15 AM", isMine: true),
            .init(body: contact.lastMessage, timestamp: contact.lastTime, isMine: false)
        ]
        chatThreads[contact.id] = seed
        return seed
    }

    func sendMessage(to contact: ChatContact, body: String) {
        let trimmed = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var thread = messages(for: contact)
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        thread.append(ChatMessage(body: trimmed, timestamp: formatter.string(from: Date()), isMine: true))
        chatThreads[contact.id] = thread
    }
}

// MARK: - Side types

struct SystemMetrics: Equatable {
    var cpu: Int
    var memory: Int
    var disk: Int
    var network: Int
}

struct UserStats: Equatable {
    var total: Int
    var active: Int
    var newToday: Int
    var premium: Int
}

// MARK: - Seeds

extension AppState {

    static let seedEmails: [EmailMessage] = [
        .init(id: 1, from: "John Doe",      subject: "Project Update",
              preview: "Here's the latest update on the project…",
              body: "Hi team,\n\nQuick update on the rollout. We're on track for Friday.\n\nBest,\nJohn",
              time: "10:30 AM", unread: true,  starred: false),
        .init(id: 2, from: "Jane Smith",    subject: "Meeting Tomorrow",
              preview: "Let's discuss the upcoming presentation…",
              body: "Hey — can we sync at 2pm tomorrow to review the deck?",
              time: "9:15 AM",  unread: false, starred: true),
        .init(id: 3, from: "Mike Johnson",  subject: "Contract Review",
              preview: "Please review the attached contract…",
              body: "Sending the latest contract draft for your review. Comments by EOD please.",
              time: "Yesterday", unread: true, starred: false),
        .init(id: 4, from: "Lisa Park",     subject: "Welcome to the team!",
              preview: "Excited to have you on board…",
              body: "Welcome! Reach out anytime.",
              time: "Mon",       unread: false, starred: false),
        .init(id: 5, from: "Carlos Rivera", subject: "Q2 sales numbers",
              preview: "Final cut attached. Highlights in the email…",
              body: "Final Q2 results. We beat the target by 8%.",
              time: "Sun",       unread: false, starred: true),
    ]

    static var seedEvents: [CalendarEvent] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        func at(_ hour: Int, _ offsetDays: Int = 0, mins: Int = 0) -> Date {
            cal.date(byAdding: .day, value: offsetDays,
                     to: cal.date(bySettingHour: hour, minute: mins, second: 0, of: today)!)!
        }
        return [
            .init(title: "Team standup",    date: at(9),       durationMinutes: 30,
                  location: "Manager Room", participants: ["Sarah", "Mike", "Lisa"], kind: .meeting),
            .init(title: "Client call - Acme", date: at(11),    durationMinutes: 45,
                  location: "Phone", participants: ["John (client)"], kind: .call),
            .init(title: "Focus block",     date: at(14),       durationMinutes: 90,
                  location: "—", participants: [], kind: .focus),
            .init(title: "Quarterly review",date: at(15, 1),    durationMinutes: 60,
                  location: "Boardroom", participants: ["Exec team"], kind: .meeting),
            .init(title: "Submit report",   date: at(17, 2),    durationMinutes: 0,
                  location: "—", participants: [], kind: .deadline),
            .init(title: "1:1 with Sarah",  date: at(10, 3),    durationMinutes: 30,
                  location: "Phone", participants: ["Sarah"], kind: .meeting),
        ]
    }

    static let seedMeetings: [Meeting] = [
        .init(title: "Weekly sync",    time: "10:00 AM", participants: ["Sarah", "Mike", "+3"], status: .upcoming),
        .init(title: "Client review",  time: "11:30 AM", participants: ["John (Acme)"],         status: .startingSoon),
        .init(title: "Design crit",    time: "2:00 PM",  participants: ["Lisa", "Tom"],         status: .upcoming),
    ]

    static let seedNotes: [ClientNote] = [
        .init(date: "2024-03-15 14:30", type: .call,        disposition: "Follow-up Required",
              agent: "John Smith",     duration: "15 min",
              body: "Client expressed interest in premium package. Requested follow-up with detailed pricing."),
        .init(date: "2024-03-15 11:45", type: .meeting,     disposition: "Completed",
              agent: "Sarah Johnson",  duration: "30 min",
              body: "Reviewed policy options. Client leaning towards standard coverage."),
        .init(date: "2024-03-14 16:00", type: .email,       disposition: "Pending Response",
              agent: "Mike Brown",     duration: "—",
              body: "Sent follow-up email with requested documentation. Awaiting client response."),
        .init(date: "2024-03-13 09:15", type: .application, disposition: "Submitted",
              agent: "AGT-78945",      duration: "—",
              body: "Application APP-2024-00321 submitted successfully. Premium Coverage Plan, family, $350/mo."),
    ]

    static let seedDrive: [DriveFile] = [
        .init(name: "Q2 Reports",          kind: .folder, size: "—",      modified: "Apr 12", owner: "You"),
        .init(name: "Onboarding",          kind: .folder, size: "—",      modified: "Mar 30", owner: "You"),
        .init(name: "Company OKRs.docx",   kind: .doc,    size: "248 KB", modified: "Today",  owner: "Sarah J."),
        .init(name: "Sales pipeline.xlsx", kind: .sheet,  size: "1.2 MB", modified: "Yest.",  owner: "You"),
        .init(name: "All-hands deck.pptx", kind: .slides, size: "8.4 MB", modified: "Mon",    owner: "Lisa P."),
        .init(name: "Master agreement.pdf",kind: .pdf,    size: "612 KB", modified: "Mar 28", owner: "Legal"),
        .init(name: "team-photo.jpg",      kind: .image,  size: "3.1 MB", modified: "Mar 14", owner: "You"),
    ]

    static let seedContacts: [ChatContact] = [
        .init(name: "Sarah Johnson",  email: "sarah.j@brownandsullivan.com",  lastMessage: "Sounds good — let's sync at 2.", lastTime: "10:14 AM", initials: "SJ", online: true),
        .init(name: "Michael Chen",   email: "mchen@brownandsullivan.com",    lastMessage: "I pushed the new revisions.",     lastTime: "9:48 AM",  initials: "MC", online: true),
        .init(name: "Lisa Park",      email: "lpark@brownandsullivan.com",    lastMessage: "Perfect, thank you!",             lastTime: "Yest.",    initials: "LP"),
        .init(name: "Carlos Rivera",  email: "crivera@brownandsullivan.com",  lastMessage: "Numbers look great.",             lastTime: "Mon",      initials: "CR"),
        .init(name: "Tom Hayes",      email: "thayes@brownandsullivan.com",   lastMessage: "Lunch tomorrow?",                 lastTime: "Sun",      initials: "TH"),
    ]

    static let seedCalls: [ClientCall] = [
        .init(name: "Acme Corp – John D.",  phone: "+1 (415) 555-0188", lastCall: "Today, 10:14 AM", tags: ["Hot lead", "Enterprise"], initials: "JD"),
        .init(name: "Northwind – Mary P.",  phone: "+1 (212) 555-0142", lastCall: "Today, 9:02 AM",  tags: ["Renewal"],                initials: "MP"),
        .init(name: "Globex – Henry K.",    phone: "+1 (646) 555-0119", lastCall: "Yesterday",       tags: ["DNC"],                    initials: "HK"),
        .init(name: "Initech – Pam B.",     phone: "+1 (305) 555-0167", lastCall: "Mon",             tags: ["Quote sent"],             initials: "PB"),
    ]

    static let seedActivity: [ActivityItem] = [
        .init(icon: "envelope.fill",     title: "New email from Jane Smith", detail: "Meeting Tomorrow",        time: "5m",  tint: Theme.color.info),
        .init(icon: "phone.fill",        title: "Call completed",            detail: "Acme Corp – 14m 32s",     time: "23m", tint: Theme.color.success),
        .init(icon: "doc.text.fill",     title: "Application submitted",    detail: "APP-2024-00321",          time: "1h",  tint: Theme.color.primary),
        .init(icon: "person.badge.plus", title: "New lead added",           detail: "Henry K. (Globex)",       time: "3h",  tint: Theme.color.warning),
    ]

    static let seedStats: [StatMetric] = [
        .init(title: "Calls today",  value: "47",     delta: "+12%",  positive: true,  icon: "phone.fill",       color: Theme.color.success),
        .init(title: "Talk time",    value: "5h 22m", delta: "+8%",   positive: true,  icon: "clock.fill",       color: Theme.color.info),
        .init(title: "Conversion",   value: "18.3%",  delta: "-1.2%", positive: false, icon: "arrow.up.right",   color: Theme.color.warning),
        .init(title: "Revenue",      value: "$24,180",delta: "+22%",  positive: true,  icon: "dollarsign.circle.fill", color: Theme.color.primary),
    ]

    static let seedSales: [SaleRow] = [
        .init(agent: "Alex Morgan",   plan: "Premium Family", premium: "$350", date: "Today",     status: "Approved"),
        .init(agent: "Sarah Johnson", plan: "Standard",       premium: "$210", date: "Today",     status: "Pending"),
        .init(agent: "Mike Brown",    plan: "Premium Single", premium: "$185", date: "Yesterday", status: "Approved"),
        .init(agent: "Lisa Park",     plan: "Standard",       premium: "$210", date: "Yesterday", status: "Approved"),
        .init(agent: "Carlos Rivera", plan: "Premium Family", premium: "$350", date: "Mon",       status: "Approved"),
        .init(agent: "Tom Hayes",     plan: "Standard",       premium: "$210", date: "Mon",       status: "Declined"),
    ]

    static let seedSystemStatus: [SystemComponentStatus] = [
        .init(name: "Server",   icon: "server.rack",    status: .healthy),
        .init(name: "Database", icon: "cylinder.fill",  status: .healthy),
        .init(name: "API",      icon: "network",        status: .degraded),
        .init(name: "Cache",    icon: "memorychip",     status: .healthy),
    ]

    static let seedAdminUsers: [AdminUser] = [
        .init(name: "Alex Morgan",  email: "alex.morgan@brownandsullivan.com",  role: "Admin",  status: "Active",   lastActive: "Now"),
        .init(name: "Sarah Johnson",email: "sarah.j@brownandsullivan.com",      role: "Agent",  status: "Active",   lastActive: "2m ago"),
        .init(name: "Michael Chen", email: "mchen@brownandsullivan.com",        role: "Agent",  status: "Active",   lastActive: "10m ago"),
        .init(name: "Lisa Park",    email: "lpark@brownandsullivan.com",        role: "Agent",  status: "Idle",     lastActive: "1h ago"),
        .init(name: "Carlos Rivera",email: "crivera@brownandsullivan.com",      role: "Manager",status: "Active",   lastActive: "5m ago"),
        .init(name: "Tom Hayes",    email: "thayes@brownandsullivan.com",       role: "Agent",  status: "Offline",  lastActive: "2h ago"),
    ]

    static let seedAdminActivity: [AdminActivity] = [
        .init(kind: .userAction,     user: "John Doe", message: "Updated profile",            timestamp: "5 minutes ago"),
        .init(kind: .systemAlert,    user: nil,        message: "High CPU usage detected",     timestamp: "15 minutes ago"),
        .init(kind: .securityAlert,  user: nil,        message: "Failed login attempts (×4)",  timestamp: "30 minutes ago"),
        .init(kind: .userAction,     user: "Sarah J.", message: "Submitted application",       timestamp: "1 hour ago"),
    ]

    // MARK: - PressBox (Campaign-main) seeds

    static var seedPressEvents: [PressEvent] {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let d0 = CampaignDateFormat.storageString(from: start)
        let d1 = CampaignDateFormat.storageString(from: cal.date(byAdding: .day, value: 1, to: start)!)
        let d2 = CampaignDateFormat.storageString(from: cal.date(byAdding: .day, value: 3, to: start)!)
        return [
            PressEvent(id: 1, title: "Team Meeting",      time: "2:00 PM",  date: d0, type: .meeting),
            PressEvent(id: 2, title: "Content Review",    time: "11:00 AM", date: d1, type: .review),
            PressEvent(id: 3, title: "Campaign Launch",   time: "9:00 AM",  date: d2, type: .event),
        ]
    }

    static let seedMarketingTasks: [MarketingTaskItem] = [
        .init(id: 1, title: "Review Q2 Marketing Plan",
              description: "Review and provide feedback on the Q2 marketing strategy and budget allocation.",
              dueDate: "Today", priority: "High", status: "In Progress", assignedBy: "Sarah Johnson"),
        .init(id: 2, title: "Create Social Media Posts",
              description: "Design and schedule social media content for the upcoming product launch.",
              dueDate: "Tomorrow", priority: "Medium", status: "Not Started", assignedBy: "Mike Chen"),
        .init(id: 3, title: "Update Website Content",
              description: "Refresh the website content with new product information and customer testimonials.",
              dueDate: "Next Week", priority: "Low", status: "In Progress", assignedBy: "Lisa Wong"),
    ]

    static let seedCampaignInbox: [CampaignInboxPerson] = [
        .init(id: 1, name: "Sarah Johnson",  role: "Content Manager", lastMessage: "Thanks for the feedback on the Q2 campaign!",
              timestamp: "2 min ago", unread: 0, presence: .online, initials: "SJ"),
        .init(id: 2, name: "Mike Chen",      role: "Marketing Director", lastMessage: "Can we schedule a meeting for next week?",
              timestamp: "1 hour ago", unread: 2, presence: .away, initials: "MC"),
        .init(id: 3, name: "Emily Rodriguez", role: "Design Lead", lastMessage: "The new mockups are ready for review",
              timestamp: "3 hours ago", unread: 0, presence: .offline, initials: "ER"),
        .init(id: 4, name: "David Kim",      role: "Analytics Specialist", lastMessage: "The campaign metrics look promising",
              timestamp: "1 day ago", unread: 1, presence: .online, initials: "DK"),
    ]

    static let seedCampaignThreads: [Int: [CampaignThreadMessage]] = [
        1: [
            .init(id: 1, sender: "Sarah Johnson", content: "Hi! I wanted to follow up on the Q2 campaign strategy we discussed.",
                  timestamp: "10:30 AM", isOwn: false),
            .init(id: 2, sender: "You", content: "Thanks for reaching out! I've reviewed the proposal and it looks great.",
                  timestamp: "10:32 AM", isOwn: true),
            .init(id: 3, sender: "Sarah Johnson", content: "Perfect! Should we schedule a team meeting to discuss the implementation?",
                  timestamp: "10:35 AM", isOwn: false),
            .init(id: 4, sender: "You", content: "Yes, that sounds good. How about next Tuesday at 2 PM?",
                  timestamp: "10:36 AM", isOwn: true),
            .init(id: 5, sender: "Sarah Johnson", content: "Thanks for the feedback on the Q2 campaign!",
                  timestamp: "2 min ago", isOwn: false),
        ],
        2: [
            .init(id: 1, sender: "Mike Chen", content: "Can we schedule a meeting for next week?",
                  timestamp: "1 hour ago", isOwn: false),
        ],
        3: [
            .init(id: 1, sender: "Emily Rodriguez", content: "The new mockups are ready for review",
                  timestamp: "3 hours ago", isOwn: false),
        ],
        4: [
            .init(id: 1, sender: "David Kim", content: "The campaign metrics look promising",
                  timestamp: "1 day ago", isOwn: false),
        ],
    ]

    static let seedAccountSnapshot = CampaignAccountSnapshot(
        currentBalance: 18_400.50,
        previousBalance: 16_200.75,
        totalEarnings: 28_400.25,
        totalSpent: 9_999.75,
        pendingAmount: 1_250.00
    )

    static let seedCampaignTransactions: [CampaignTransaction] = [
        .init(id: 1,  isCredit: true,  amount: 2_500.00,  description: "Campaign Revenue - Q4 Marketing", date: "2024-01-21", status: "completed"),
        .init(id: 2,  isCredit: false, amount: -450.00,   description: "Ad Spend - Facebook Campaign",   date: "2024-01-20", status: "completed"),
        .init(id: 3,  isCredit: true,  amount: 1_800.00,  description: "Content Monetization",          date: "2024-01-19", status: "completed"),
        .init(id: 4,  isCredit: false, amount: -320.00,   description: "Google Ads Budget",             date: "2024-01-18", status: "completed"),
        .init(id: 5,  isCredit: true,  amount: 1_250.00,  description: "Affiliate Commission",          date: "2024-01-17", status: "pending"),
        .init(id: 6,  isCredit: false, amount: -150.00,   description: "Software Subscription",         date: "2024-01-16", status: "completed"),
        .init(id: 7,  isCredit: true,  amount: 3_200.00,  description: "Brand Partnership",           date: "2024-01-15", status: "completed"),
        .init(id: 8,  isCredit: false, amount: -280.00,   description: "Design Tools License",          date: "2024-01-14", status: "completed"),
    ]

    static let seedIntelligenceArticles: [IntelligenceArticle] = [
        .init(id: 1,  title: "Marketing Strategy Guide",      views: 15_420, engagement: 94, publishDate: "2024-01-21", status: "Published", category: "Strategy"),
        .init(id: 2,  title: "Q4 Campaign Brief",             views: 12_850, engagement: 87, publishDate: "2024-01-20", status: "Updated",   category: "Campaign"),
        .init(id: 3,  title: "Social Media Best Practices",   views: 9_650,  engagement: 91, publishDate: "2024-01-19", status: "Published", category: "Social Media"),
        .init(id: 4,  title: "Content Calendar Template",     views: 11_200, engagement: 89, publishDate: "2024-01-18", status: "Draft",     category: "Templates"),
        .init(id: 5,  title: "Email Marketing Automation",   views: 8_750,  engagement: 88, publishDate: "2024-01-17", status: "Published", category: "Email"),
        .init(id: 6,  title: "SEO Optimization Tips",         views: 14_200, engagement: 92, publishDate: "2024-01-16", status: "Published", category: "SEO"),
        .init(id: 7,  title: "Brand Guidelines Update",       views: 6_800,  engagement: 85, publishDate: "2024-01-15", status: "Updated",   category: "Brand"),
        .init(id: 8,  title: "Analytics Dashboard Setup",     views: 9_200,  engagement: 90, publishDate: "2024-01-14", status: "Published", category: "Analytics"),
        .init(id: 9,  title: "Video Content Strategy",        views: 10_500, engagement: 87, publishDate: "2024-01-13", status: "Published", category: "Video"),
        .init(id: 10, title: "Customer Journey Mapping",      views: 7_800,  engagement: 89, publishDate: "2024-01-12", status: "Draft",     category: "Strategy"),
    ]

    static var seedPerformanceDays: [PerformanceDayRow] {
        let cal = Calendar.current
        var rows: [PerformanceDayRow] = []
        for offset in (0..<14).reversed() {
            guard let d = cal.date(byAdding: .day, value: -offset, to: Date()) else { continue }
            let spend = Double((offset * 17 + 31) % 400 + 100)
            let revenue = Double((offset * 23 + 50) % 900 + 200)
            let roas = min(300, max(50, (revenue / max(1, spend)) * 100))
            let f = DateFormatter()
            f.dateStyle = .short
            let label = f.string(from: d)
            rows.append(PerformanceDayRow(id: 14 - offset, label: label, spend: spend, revenue: revenue, roas: roas))
        }
        return rows
    }

    static let seedCampaignSummaries: [NamedCampaignSummary] = [
        .init(id: 1, name: "Summer Sale", spend: 1_200, revenue: 2_400, roas: 200),
        .init(id: 2, name: "Product Launch", spend: 800, revenue: 1_400, roas: 175),
        .init(id: 3, name: "Brand Awareness", spend: 600, revenue: 950, roas: 158),
    ]

    static let seedBIWeek: [BIDayPoint] = [
        .init(id: 0, day: "Mon", engagement: 78, views: 1_250),
        .init(id: 1, day: "Tue", engagement: 95, views: 2_100),
        .init(id: 2, day: "Wed", engagement: 82, views: 1_750),
        .init(id: 3, day: "Thu", engagement: 97, views: 2_300),
        .init(id: 4, day: "Fri", engagement: 85, views: 1_950),
        .init(id: 5, day: "Sat", engagement: 72, views: 1_400),
        .init(id: 6, day: "Sun", engagement: 68, views: 1_200),
    ]
}
