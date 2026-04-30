import Foundation
import SwiftUI

// MARK: - Email

struct EmailMessage: Identifiable, Hashable {
    let id: Int
    let from: String
    let subject: String
    let preview: String
    let body: String
    let time: String
    var unread: Bool
    var starred: Bool
}

enum EmailFolder: String, CaseIterable, Identifiable {
    case inbox = "Inbox"
    case starred = "Starred"
    case sent = "Sent"
    case drafts = "Drafts"
    case trash = "Trash"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .inbox: "tray"
        case .starred: "star"
        case .sent: "paperplane"
        case .drafts: "doc.text"
        case .trash: "trash"
        }
    }
}

// MARK: - Calendar

struct CalendarEvent: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let date: Date
    let durationMinutes: Int
    let location: String
    let participants: [String]
    let kind: Kind

    enum Kind: String { case meeting, call, deadline, focus }

    var color: Color {
        switch kind {
        case .meeting: Theme.color.info
        case .call: Theme.color.success
        case .deadline: Theme.color.danger
        case .focus: Theme.color.warning
        }
    }
}

// MARK: - Meetings

struct Meeting: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let time: String
    let participants: [String]
    let status: Status

    enum Status: String { case upcoming, startingSoon, inProgress }

    var accent: Color {
        switch status {
        case .upcoming: Theme.color.info
        case .startingSoon: Theme.color.warning
        case .inProgress: Theme.color.success
        }
    }
}

// MARK: - Notes (call/meeting/email/application history)

struct ClientNote: Identifiable, Hashable {
    let id = UUID()
    let date: String
    let type: NoteType
    let disposition: String
    let agent: String
    let duration: String
    let body: String

    enum NoteType: String, CaseIterable { case call = "Call", meeting = "Meeting", email = "Email", application = "Application" }

    var icon: String {
        switch type {
        case .call: "phone.fill"
        case .meeting: "video.fill"
        case .email: "envelope.fill"
        case .application: "doc.text.fill"
        }
    }
}

// MARK: - Drive

struct DriveFile: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let kind: Kind
    let size: String
    let modified: String
    let owner: String

    enum Kind: String { case folder, doc, sheet, slides, pdf, image, other }

    var icon: String {
        switch kind {
        case .folder: "folder.fill"
        case .doc: "doc.text.fill"
        case .sheet: "tablecells.fill"
        case .slides: "rectangle.stack.fill"
        case .pdf: "doc.richtext.fill"
        case .image: "photo.fill"
        case .other: "doc.fill"
        }
    }

    var color: Color {
        switch kind {
        case .folder: Theme.color.warning
        case .doc: Theme.color.info
        case .sheet: Theme.color.success
        case .slides: Color(hex: 0xF97316)
        case .pdf: Theme.color.danger
        case .image: Color(hex: 0x8B5CF6)
        case .other: Theme.color.secondary
        }
    }
}

// MARK: - Chat

struct ChatContact: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let email: String
    let lastMessage: String
    let lastTime: String
    let initials: String
    var online: Bool = false
}

struct ChatMessage: Identifiable, Hashable {
    let id = UUID()
    let body: String
    let timestamp: String
    let isMine: Bool
}

// MARK: - Recent calls / clients

struct ClientCall: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let phone: String
    let lastCall: String
    let tags: [String]
    let initials: String
}

// MARK: - Activity

struct ActivityItem: Identifiable, Hashable {
    let id = UUID()
    let icon: String
    let title: String
    let detail: String
    let time: String
    let tint: Color
}

// MARK: - Analytics

struct StatMetric: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let value: String
    let delta: String
    let positive: Bool
    let icon: String
    let color: Color
}

struct SaleRow: Identifiable, Hashable {
    let id = UUID()
    let agent: String
    let plan: String
    let premium: String
    let date: String
    let status: String
}

// MARK: - AI Assistant

struct AIChatMessage: Identifiable, Hashable {
    let id = UUID()
    let role: Role
    let body: String

    enum Role { case user, assistant }
}

// MARK: - Admin

struct SystemComponentStatus: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    var status: Health
}

enum Health: String { case healthy, degraded, down

    var color: Color {
        switch self {
        case .healthy: Theme.color.success
        case .degraded: Theme.color.warning
        case .down: Theme.color.danger
        }
    }

    var label: String {
        switch self {
        case .healthy: "Healthy"
        case .degraded: "Degraded"
        case .down: "Down"
        }
    }
}

struct AdminUser: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let email: String
    let role: String
    let status: String
    let lastActive: String
}

struct AdminActivity: Identifiable, Hashable {
    let id = UUID()
    let kind: Kind
    let user: String?
    let message: String
    let timestamp: String

    enum Kind { case userAction, systemAlert, securityAlert

        var icon: String {
            switch self {
            case .userAction: "person.fill"
            case .systemAlert: "exclamationmark.triangle.fill"
            case .securityAlert: "lock.shield.fill"
            }
        }

        var color: Color {
            switch self {
            case .userAction: Theme.color.info
            case .systemAlert: Theme.color.warning
            case .securityAlert: Theme.color.danger
            }
        }
    }
}

// MARK: - Office app launcher items (the "iOS app grid" on the home tab)

struct OfficeAppShortcut: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let icon: String
    let gradient: [Color]
    let destinationTab: OfficeTab
}

// MARK: - Office tabs

enum OfficeTab: String, CaseIterable, Identifiable {
    case home, dialer, email, calendar, drive, chat, analytics, settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: "Home"
        case .dialer: "Dialer"
        case .email: "Email"
        case .calendar: "Calendar"
        case .drive: "Drive"
        case .chat: "Chat"
        case .analytics: "Analytics"
        case .settings: "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: "house.fill"
        case .dialer: "phone.fill"
        case .email: "envelope.fill"
        case .calendar: "calendar"
        case .drive: "folder.fill"
        case .chat: "message.fill"
        case .analytics: "chart.bar.fill"
        case .settings: "gearshape.fill"
        }
    }
}

// MARK: - Agent disposition

enum AgentDisposition: String, CaseIterable, Identifiable {
    case active = "Active"
    case break_ = "Break"
    case lunch = "Lunch"
    case meeting = "Meeting"
    case training = "Training"
    case admin = "Admin"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .active: Theme.color.success
        case .break_, .lunch: Theme.color.warning
        case .meeting: Theme.color.info
        case .training: Theme.color.primary
        case .admin: Theme.color.secondary
        }
    }

    var icon: String {
        switch self {
        case .active: "checkmark.circle.fill"
        case .break_: "cup.and.saucer.fill"
        case .lunch: "fork.knife"
        case .meeting: "video.fill"
        case .training: "graduationcap.fill"
        case .admin: "person.crop.circle.badge.checkmark"
        }
    }
}
