import SwiftUI

/// Visual tokens for **PressBox** / Marketing Hub (Campaign Next.js app:
/// indigo gradient hero, gray surfaces).
enum PressBoxTheme {
    static let indigo = Color(hex: 0x4F46E5)
    static let indigoDark = Color(hex: 0x4338CA)
    static let indigoLight = Color(hex: 0xEEF2FF)
    static let background = Color(hex: 0xF9FAFB)
    static let surface = Color.white
    static let textPrimary = Color(hex: 0x111827)
    static let textSecondary = Color(hex: 0x6B7280)
    static let border = Color(hex: 0xE5E7EB)

    static let heroGradient = LinearGradient(
        colors: [Color(hex: 0xEEF2FF), Color(hex: 0xEFF6FF)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static func chip(for status: String) -> (Color, Color) {
        switch status {
        case "Completed": (Color(hex: 0xD1FAE5), Color(hex: 0x065F46))
        case "In Progress": (Color(hex: 0xFEF3C7), Color(hex: 0x92400E))
        case "Not Started": (Color(hex: 0xF3F4F6), Color(hex: 0x374151))
        case "Published", "Approved": (Color(hex: 0xD1FAE5), Color(hex: 0x065F46))
        case "Draft": (Color(hex: 0xE5E7EB), Color(hex: 0x374151))
        case "Updated": (Color(hex: 0xDBEAFE), Color(hex: 0x1E40AF))
        case "Declined": (Color(hex: 0xFEE2E2), Color(hex: 0x991B1B))
        case "pending": (Color(hex: 0xFEF9C3), Color(hex: 0x854D0E))
        case "completed": (Color(hex: 0xD1FAE5), Color(hex: 0x065F46))
        default: (PressBoxTheme.indigoLight.opacity(0.6), PressBoxTheme.indigoDark)
        }
    }
}

extension View {
    func pressBoxCard() -> some View {
        self
            .background(PressBoxTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}
