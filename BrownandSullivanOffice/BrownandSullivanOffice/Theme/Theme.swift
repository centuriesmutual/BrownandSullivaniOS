import SwiftUI

/// Design tokens mirroring the CSS custom properties in the original web app's
/// `app/globals.css` (`:root` block). Use `Theme.color.primary` etc.
enum Theme {

    // MARK: - Colors (from --primary-color, --secondary-color, ...)

    enum Palette {
        static let primary       = Color(hex: 0x1A73E8)   // Google blue
        static let primaryDeep   = Color(hex: 0x2563EB)
        static let secondary     = Color(hex: 0x64748B)
        static let success       = Color(hex: 0x22C55E)
        static let warning       = Color(hex: 0xF59E0B)
        static let danger        = Color(hex: 0xEF4444)
        static let info          = Color(hex: 0x3B82F6)
        static let background    = Color(hex: 0xF1F5F9)
        static let cardBackground = Color(hex: 0xFFFFFF)
        static let textPrimary   = Color(hex: 0x1E293B)
        static let textSecondary = Color(hex: 0x64748B)
        static let border        = Color(hex: 0xE2E8F0)
        static let surfaceMuted  = Color(hex: 0xF8FAFC)
    }

    // MARK: - Gradients

    enum Gradients {
        static let primary = LinearGradient(
            colors: [Color(hex: 0x1A73E8), Color(hex: 0x4285F4)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        static let loginBg = LinearGradient(
            colors: [Color(hex: 0x1A365D), Color(hex: 0x2D3748)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        static let cardHeader = LinearGradient(
            colors: [Color(hex: 0xF8FAFC), Color(hex: 0xF1F5F9)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        static let aiPanel = LinearGradient(
            colors: [Color(hex: 0xF8FAFC), Color(hex: 0xF1F5F9)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Spacing

    enum Spacing {
        static let xs: CGFloat = 4
        static let s: CGFloat = 8
        static let m: CGFloat = 12
        static let l: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    // MARK: - Radius

    enum Radius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xl: CGFloat = 20
    }

    // MARK: - Shadows

    enum Shadow {
        static let card = (
            color: Color.black.opacity(0.05),
            radius: CGFloat(20),
            x: CGFloat(0),
            y: CGFloat(4)
        )
        static let cardHover = (
            color: Color.black.opacity(0.10),
            radius: CGFloat(30),
            x: CGFloat(0),
            y: CGFloat(12)
        )
    }

    // MARK: - Productivity suite chrome (Google / Apple workspace + partner cues)

    /// Surfaces and accents that read as “Workspace” + RingCentral telephony + Dropbox cloud.
    enum Suite {
        /// Apple-style grouped background
        static let chromeBackground = Color(hex: 0xF5F5F7)
        static let elevatedSurface = Color(hex: 0xFFFFFF)
        /// RingCentral-style accent for CTAs and line status
        static let ringAccent = Color(hex: 0xF47B20)
        static let lineConnected = Color(hex: 0x00A651)
        static let lineDisconnected = Color(hex: 0xE01E5A)
        /// Dropbox-style folder and cloud emphasis
        static let cloudBlue = Color(hex: 0x0061FF)
        static let cloudBlueSoft = Color(hex: 0xE8F3FF)
        /// Google Workspace–style subtle focus ring
        static let focusBlue = Color(hex: 0x1A73E8).opacity(0.22)
        static let separator = Color(hex: 0xE5E5EA)
    }

    // MARK: - Aliases

    static let color = Palette.self
    static let gradient = Gradients.self
    static let spacing = Spacing.self
    static let radius = Radius.self
}

// MARK: - Color hex initializer

extension Color {
    /// Create a Color from a 24-bit RGB value, e.g. `Color(hex: 0x1A73E8)`.
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

// MARK: - Convenience view modifiers

extension View {
    /// Apply the standard "dashboard card" styling used across the dashboard.
    func dashboardCardStyle() -> some View {
        self
            .background(Theme.color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.radius.xl, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radius.xl, style: .continuous)
                    .stroke(Theme.Suite.separator.opacity(0.7), lineWidth: 1)
            )
            .shadow(
                color: Theme.Shadow.card.color,
                radius: Theme.Shadow.card.radius,
                x: Theme.Shadow.card.x,
                y: Theme.Shadow.card.y
            )
    }

    /// Standard screen fill for Office tabs (Apple Settings / Google-style neutral).
    func suiteGroupedBackground() -> some View {
        self.background(Theme.Suite.chromeBackground.ignoresSafeArea())
    }

    /// Navigation bar + tab tint consistent with workspace chrome.
    func suiteNavigationChrome() -> some View {
        self
            .toolbarBackground(Theme.Suite.elevatedSurface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}
