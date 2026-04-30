import Foundation
import SwiftUI
import Combine

/// Top-level navigation root.
enum AppRoot: Equatable {
    case login
    case office
    case admin
}

/// Single source of truth for the app. Mirrors the seeded fixtures from the
/// original Next.js app's `app/office/page.js` and `app/admin/page.js`.
@MainActor
final class AppState: ObservableObject {

    // MARK: - Routing
    @Published var activeRoot: AppRoot = .login
    @Published var officeTab: OfficeTab = .home

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
        userInitials = String(email.prefix(2)).uppercased()
        activeRoot = .office
        officeTab = .home
        return true
    }

    func signOut() {
        activeRoot = .login
    }

    func switchToAdmin() {
        activeRoot = .admin
    }

    func backToOffice() {
        activeRoot = .office
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
}
