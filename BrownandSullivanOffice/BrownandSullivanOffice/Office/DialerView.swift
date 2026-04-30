import SwiftUI

/// RingCentral-inspired phone: line status, HD VoIP chrome, keypad, and recent callbacks.
struct DialerView: View {
    @EnvironmentObject private var app: AppState
    @State private var phoneNumber: String = ""
    @State private var callStatus: CallStatus = .idle
    @State private var callSeconds: Int = 0
    @State private var connected: Bool = false
    @State private var timer: Timer?
    @State private var showEnrollment = false
    @State private var keypadMode: KeypadMode = .numbers

    enum CallStatus: String {
        case idle = "Idle"
        case dialing = "Dialing…"
        case connected = "On call"
    }

    enum KeypadMode: String, CaseIterable, Hashable {
        case numbers = "123"
        case recents = "Recent"
    }

    private let keys: [(String, String)] = [
        ("1", ""), ("2", "ABC"), ("3", "DEF"),
        ("4", "GHI"), ("5", "JKL"), ("6", "MNO"),
        ("7", "PQRS"), ("8", "TUV"), ("9", "WXYZ"),
        ("*", ""), ("0", "+"), ("#", "")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing.l) {
                voipLineCard
                Picker("", selection: $keypadMode) {
                    ForEach(KeypadMode.allCases, id: \.self) { m in
                        Text(m.rawValue).tag(m)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 2)

                if keypadMode == .numbers {
                    numberDisplay
                    activeCallStrip
                    dialPadGrid
                    callControlRow
                    communicationsShortcuts
                } else {
                    recentsListCard
                }
            }
            .padding(Theme.spacing.l)
        }
        .sheet(isPresented: $showEnrollment) {
            EnrollmentSheet(phone: phoneNumber)
        }
    }

    // MARK: - Line / PBX (RingCentral-style)

    private var voipLineCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill((connected ? Theme.Suite.lineConnected : Theme.Suite.lineDisconnected).opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "phone.connection")
                        .font(.title3)
                        .foregroundStyle(connected ? Theme.Suite.lineConnected : Theme.Suite.lineDisconnected)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(connected ? "Business line · Registered" : "Business line · Not registered")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.color.textPrimary)
                    Text(connected ? "VoIP · HD Voice · TLS" : "Connect to place calls and receive queue")
                        .font(.caption)
                        .foregroundStyle(Theme.color.textSecondary)
                }
                Spacer()
                Button {
                    connected.toggle()
                } label: {
                    Text(connected ? "Disconnect" : "Connect")
                        .font(.subheadline.weight(.bold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(connected ? Theme.Suite.lineDisconnected.opacity(0.12) : Theme.Suite.ringAccent.opacity(0.15))
                        .foregroundStyle(connected ? Theme.Suite.lineDisconnected : Theme.Suite.ringAccent)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            Divider().opacity(0.5)
            HStack {
                Label("Presence", systemImage: "dot.radiowaves.left.and.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.color.textSecondary)
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundStyle(Theme.Suite.lineConnected)
                    Text("Secure RTP")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Theme.color.textSecondary)
                }
            }
        }
        .padding(16)
        .background(Theme.Suite.elevatedSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Theme.Suite.separator.opacity(0.8), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    }

    private var numberDisplay: some View {
        Text(phoneNumber.isEmpty ? " " : phoneNumber)
            .font(.system(size: 34, weight: .medium, design: .rounded))
            .foregroundStyle(phoneNumber.isEmpty ? Theme.color.textSecondary.opacity(0.35) : Theme.color.textPrimary)
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .padding(.horizontal, 16)
            .background(Theme.Suite.chromeBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Theme.Suite.focusBlue, lineWidth: phoneNumber.isEmpty ? 1 : 2)
            )
    }

    @ViewBuilder
    private var activeCallStrip: some View {
        if callStatus != .idle {
            HStack(spacing: 12) {
                StatusDot(color: callStatus == .connected ? Theme.Suite.lineConnected : Theme.color.warning,
                          pulse: callStatus == .dialing)
                Text(callStatus.rawValue)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                if callStatus == .connected {
                    Text(formatDuration(callSeconds))
                        .font(.subheadline.monospacedDigit().weight(.medium))
                        .foregroundStyle(Theme.color.textSecondary)
                }
            }
            .padding(12)
            .background(Theme.Suite.cloudBlueSoft.opacity(0.35))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private var dialPadGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 3), spacing: 14) {
            ForEach(keys, id: \.0) { digit, letters in
                Button { tapKey(digit) } label: {
                    VStack(spacing: 4) {
                        Text(digit)
                            .font(.system(size: 28, weight: .medium, design: .rounded))
                        if !letters.isEmpty {
                            Text(letters)
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundStyle(Theme.color.textSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.Suite.elevatedSurface)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Theme.Suite.separator, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(.plain)
                .disabled(!connected)
            }
        }
        .opacity(connected ? 1 : 0.45)
    }

    private var callControlRow: some View {
        HStack(spacing: 20) {
            dialActionButton(icon: "delete.left.fill", tint: Theme.color.secondary) {
                if !phoneNumber.isEmpty { phoneNumber.removeLast() }
            }
            .disabled(phoneNumber.isEmpty)

            Button(action: toggleCall) {
                Image(systemName: callStatus == .idle ? "phone.fill" : "phone.down.fill")
                    .font(.title2)
                    .frame(width: 72, height: 72)
                    .background(callStatus == .idle ? Theme.Suite.lineConnected : Theme.Suite.lineDisconnected)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
                    .shadow(color: (callStatus == .idle ? Theme.Suite.lineConnected : Theme.Suite.lineDisconnected).opacity(0.45),
                            radius: 16, y: 6)
            }
            .buttonStyle(.plain)
            .disabled(!connected || phoneNumber.isEmpty)

            dialActionButton(icon: "person.crop.circle.badge.plus", tint: Theme.Suite.cloudBlue) {
                showEnrollment = true
            }
            .disabled(phoneNumber.isEmpty)
        }
        .frame(maxWidth: .infinity)
    }

    private func dialActionButton(icon: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 56, height: 56)
                .background(tint.opacity(0.12))
                .foregroundStyle(tint)
                .clipShape(Circle())
                .overlay(Circle().stroke(tint.opacity(0.2), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var communicationsShortcuts: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(InText.shortcutsLabel)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.color.textSecondary)
            HStack(spacing: 0) {
                commChip(icon: "record.circle", title: "Voicemail")
                commChip(icon: "bubble.left.and.bubble.right.fill", title: "SMS")
                commChip(icon: "person.crop.rectangle.stack", title: "Contacts")
                commChip(icon: "video.fill", title: "Meet")
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Suite.elevatedSurface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Theme.Suite.separator.opacity(0.7), lineWidth: 1)
        )
    }

    private func commChip(icon: String, title: String) -> some View {
        Button {} label: {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(Theme.color.primary)
                Text(title)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Theme.color.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }

    private var recentsListCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Recent calls", systemImage: "clock.arrow.circlepath")
                .font(.headline)
                .foregroundStyle(Theme.color.textPrimary)
            VStack(spacing: 0) {
                ForEach(Array(app.recentCalls.enumerated()), id: \.element.id) { idx, call in
                    HStack(spacing: 12) {
                        Avatar(initials: call.initials, size: 42,
                               gradient: [Theme.Suite.ringAccent.opacity(0.85), Theme.color.primary])
                        VStack(alignment: .leading, spacing: 4) {
                            Text(call.name)
                                .font(.subheadline.weight(.semibold))
                            Text(call.phone)
                                .font(.caption)
                                .foregroundStyle(Theme.color.textSecondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 6) {
                            Text(call.lastCall)
                                .font(.caption2)
                                .foregroundStyle(Theme.color.textSecondary)
                            Button {
                                phoneNumber = stripPhone(call.phone)
                                keypadMode = .numbers
                            } label: {
                                Image(systemName: "phone.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(Theme.Suite.lineConnected)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 10)
                    if idx < app.recentCalls.count - 1 {
                        Divider()
                    }
                }
            }
        }
        .padding(16)
        .background(Theme.Suite.elevatedSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Theme.Suite.separator.opacity(0.8), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }

    // MARK: - Helpers

    private func tapKey(_ digit: String) {
        if phoneNumber.count < 18 { phoneNumber += digit }
    }

    private func toggleCall() {
        switch callStatus {
        case .idle:
            callStatus = .dialing
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                if callStatus == .dialing {
                    callStatus = .connected
                    startTimer()
                }
            }
        case .dialing, .connected:
            stopTimer()
            callStatus = .idle
            callSeconds = 0
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            callSeconds += 1
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func formatDuration(_ s: Int) -> String {
        String(format: "%02d:%02d", s / 60, s % 60)
    }

    private func stripPhone(_ p: String) -> String {
        p.filter { $0.isNumber }
    }
}

private enum InText {
    static let shortcutsLabel = "Workspace shortcuts"
}

private struct EnrollmentSheet: View {
    @Environment(\.dismiss) private var dismiss
    let phone: String

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var dob = Date()
    @State private var address = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Contact") {
                    TextField("First name", text: $firstName)
                    TextField("Last name", text: $lastName)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    LabeledContent("Phone", value: phone)
                }
                Section("Personal") {
                    DatePicker("Date of birth", selection: $dob, displayedComponents: .date)
                    TextField("Street address", text: $address)
                }
                Section("Notes") {
                    TextEditor(text: $notes).frame(minHeight: 120)
                }
            }
            .navigationTitle("New Enrollment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { dismiss() }
                        .disabled(firstName.isEmpty || lastName.isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationStack { DialerView().environmentObject(AppState()) }
}
