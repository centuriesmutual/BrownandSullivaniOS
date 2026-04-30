import SwiftUI

struct DialerView: View {
    @EnvironmentObject private var app: AppState
    @State private var phoneNumber: String = ""
    @State private var callStatus: CallStatus = .idle
    @State private var callSeconds: Int = 0
    @State private var connected: Bool = false
    @State private var timer: Timer?
    @State private var showEnrollment = false

    enum CallStatus: String { case idle = "Idle", dialing = "Dialing…", connected = "Connected" }

    private let keys: [(String, String)] = [
        ("1", ""), ("2", "ABC"), ("3", "DEF"),
        ("4", "GHI"), ("5", "JKL"), ("6", "MNO"),
        ("7", "PQRS"), ("8", "TUV"), ("9", "WXYZ"),
        ("*", ""), ("0", "+"), ("#", "")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing.l) {
                connectionStatusBar
                dialerCard
                quickActionsCard
            }
            .padding(Theme.spacing.l)
        }
        .sheet(isPresented: $showEnrollment) {
            EnrollmentSheet(phone: phoneNumber)
        }
    }

    // MARK: - Connection bar

    private var connectionStatusBar: some View {
        HStack {
            HStack(spacing: 8) {
                StatusDot(color: connected ? Theme.color.success : Theme.color.danger,
                          pulse: connected)
                Text(connected ? "Connected to PBX" : "Disconnected")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.color.textPrimary)
            }
            Spacer()
            Button {
                connected.toggle()
            } label: {
                Text(connected ? "Disconnect" : "Connect")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background((connected ? Theme.color.danger : Theme.color.success).opacity(0.12))
                    .foregroundStyle(connected ? Theme.color.danger : Theme.color.success)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .dashboardCardStyle()
    }

    // MARK: - Dialer

    private var dialerCard: some View {
        TitledCard("Dialer", icon: "phone.fill") {
            VStack(spacing: Theme.spacing.l) {
                Text(phoneNumber.isEmpty ? "Enter number" : phoneNumber)
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundStyle(phoneNumber.isEmpty ? Theme.color.textSecondary : Theme.color.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.color.surfaceMuted)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                if callStatus != .idle {
                    HStack(spacing: 10) {
                        StatusDot(color: callStatus == .connected ? Theme.color.success : Theme.color.warning,
                                  pulse: callStatus == .dialing)
                        Text(callStatus.rawValue).font(.subheadline.weight(.semibold))
                        Spacer()
                        if callStatus == .connected {
                            Text(formatDuration(callSeconds))
                                .font(.subheadline.monospacedDigit())
                                .foregroundStyle(Theme.color.textSecondary)
                        }
                    }
                    .padding(10)
                    .background(Theme.color.surfaceMuted)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3),
                          spacing: 12) {
                    ForEach(keys, id: \.0) { (digit, letters) in
                        Button { tapKey(digit) } label: {
                            VStack(spacing: 2) {
                                Text(digit).font(.system(size: 26, weight: .medium))
                                Text(letters)
                                    .font(.caption2)
                                    .foregroundStyle(Theme.color.textSecondary)
                                    .frame(height: 10)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Theme.color.surfaceMuted)
                            .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .disabled(!connected)
                    }
                }
                .opacity(connected ? 1 : 0.5)

                HStack(spacing: 16) {
                    actionButton(icon: "delete.left.fill", color: Theme.color.secondary) {
                        if !phoneNumber.isEmpty { phoneNumber.removeLast() }
                    }
                    .disabled(phoneNumber.isEmpty)

                    Button(action: toggleCall) {
                        Image(systemName: callStatus == .idle ? "phone.fill" : "phone.down.fill")
                            .font(.title2)
                            .frame(width: 64, height: 64)
                            .background(callStatus == .idle ? Theme.color.success : Theme.color.danger)
                            .foregroundStyle(.white)
                            .clipShape(Circle())
                            .shadow(color: (callStatus == .idle ? Theme.color.success : Theme.color.danger).opacity(0.4),
                                    radius: 10, y: 4)
                    }
                    .buttonStyle(.plain)
                    .disabled(!connected || phoneNumber.isEmpty)

                    actionButton(icon: "person.crop.circle.badge.plus",
                                 color: Theme.color.info) {
                        showEnrollment = true
                    }
                    .disabled(phoneNumber.isEmpty)
                }
            }
        }
    }

    private func actionButton(icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 56, height: 56)
                .background(color.opacity(0.12))
                .foregroundStyle(color)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }

    private var quickActionsCard: some View {
        TitledCard("Recent", icon: "clock.fill") {
            VStack(spacing: 0) {
                ForEach(Array(app.recentCalls.enumerated()), id: \.element.id) { idx, call in
                    HStack(spacing: 12) {
                        Avatar(initials: call.initials, size: 36)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(call.name).font(.subheadline.weight(.semibold))
                            Text(call.phone).font(.caption).foregroundStyle(Theme.color.textSecondary)
                        }
                        Spacer()
                        Button { phoneNumber = stripPhone(call.phone) } label: {
                            Image(systemName: "phone.fill")
                                .padding(8)
                                .background(Theme.color.success.opacity(0.12))
                                .foregroundStyle(Theme.color.success)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 8)
                    if idx < app.recentCalls.count - 1 { Divider() }
                }
            }
        }
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
        timer?.invalidate(); timer = nil
    }

    private func formatDuration(_ s: Int) -> String {
        String(format: "%02d:%02d", s / 60, s % 60)
    }

    private func stripPhone(_ p: String) -> String {
        p.filter { $0.isNumber }
    }
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
