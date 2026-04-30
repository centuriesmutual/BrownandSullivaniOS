import SwiftUI

struct Avatar: View {
    let initials: String
    var size: CGFloat = 36
    var gradient: [Color] = [Color(hex: 0x1A73E8), Color(hex: 0x4285F4)]

    var body: some View {
        ZStack {
            Circle().fill(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
            Text(initials.prefix(2).uppercased())
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
    }
}

struct StatusDot: View {
    let color: Color
    var pulse: Bool = false
    @State private var scale: CGFloat = 1
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 10, height: 10)
            .overlay(
                Circle().stroke(color.opacity(0.3), lineWidth: 4)
            )
            .scaleEffect(scale)
            .onAppear {
                if pulse {
                    withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                        scale = 1.15
                    }
                }
            }
    }
}
