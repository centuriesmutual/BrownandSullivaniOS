import SwiftUI

/// Simplified enrollment wizard aligned with agent application flows.
struct EnrollmentView: View {
    @State private var step = 0
    @State private var fullName = ""
    @State private var dateOfBirth = Date()
    @State private var phone = ""
    @State private var street = ""
    @State private var city = ""
    @State private var state = ""
    @State private var zip = ""
    @State private var plan: Plan = .standard
    @State private var agreed = false
    @State private var showConfirmation = false

    private enum Plan: String, CaseIterable, Identifiable {
        case standard = "Standard"
        case premium = "Premium"
        case family = "Family"

        var id: String { rawValue }

        var blurb: String {
            switch self {
            case .standard: "Core benefits, lowest premium tier."
            case .premium: "Expanded coverage and lower deductibles."
            case .family: "Household coverage with dependent add-ons."
            }
        }
    }

    private let steps = ["Applicant", "Address", "Plan", "Review"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.spacing.l) {
                stepIndicator
                Group {
                    switch step {
                    case 0: applicantStep
                    case 1: addressStep
                    case 2: planStep
                    default: reviewStep
                    }
                }
                navigationRow
            }
            .padding(Theme.spacing.l)
        }
        .alert("Application submitted", isPresented: $showConfirmation) {
            Button("OK", role: .cancel) {
                resetWizard()
            }
        } message: {
            Text("This is a demo — no data was sent to a server.")
        }
    }

    private var stepIndicator: some View {
        HStack(spacing: 8) {
            ForEach(Array(steps.enumerated()), id: \.offset) { idx, title in
                VStack(spacing: 4) {
                    Text("\(idx + 1)")
                        .font(.caption.weight(.bold))
                        .frame(width: 28, height: 28)
                        .background(idx == step ? Theme.color.primary : Theme.color.surfaceMuted)
                        .foregroundStyle(idx == step ? Color.white : Theme.color.textSecondary)
                        .clipShape(Circle())
                    Text(title)
                        .font(.caption2)
                        .foregroundStyle(idx == step ? Theme.color.textPrimary : Theme.color.textSecondary)
                }
                .frame(maxWidth: .infinity)
                if idx < steps.count - 1 {
                    Rectangle()
                        .fill(Theme.color.border)
                        .frame(height: 2)
                        .frame(maxWidth: 20)
                }
            }
        }
        .padding(.bottom, 8)
    }

    private var applicantStep: some View {
        TitledCard("Applicant", icon: "person.fill") {
            VStack(alignment: .leading, spacing: 12) {
                labeledField("Full name") {
                    TextField("Jane Doe", text: $fullName)
                        .textContentType(.name)
                        .padding(12)
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.color.border))
                }
                labeledField("Date of birth") {
                    DatePicker("", selection: $dateOfBirth, displayedComponents: .date)
                        .labelsHidden()
                }
                labeledField("Phone") {
                    TextField("(555) 000-0000", text: $phone)
                        .keyboardType(.phonePad)
                        .padding(12)
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.color.border))
                }
            }
        }
    }

    private var addressStep: some View {
        TitledCard("Mailing address", icon: "mappin.and.ellipse") {
            VStack(alignment: .leading, spacing: 12) {
                labeledField("Street") {
                    TextField("123 Main St", text: $street)
                        .padding(12)
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.color.border))
                }
                HStack(spacing: 12) {
                    labeledField("City") {
                        TextField("City", text: $city)
                            .padding(12)
                            .background(Color.white)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.color.border))
                    }
                    labeledField("State") {
                        TextField("ST", text: $state)
                            .textInputAutocapitalization(.characters)
                            .padding(12)
                            .background(Color.white)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.color.border))
                    }
                    .frame(maxWidth: 80)
                }
                labeledField("ZIP") {
                    TextField("00000", text: $zip)
                        .keyboardType(.numberPad)
                        .padding(12)
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.color.border))
                }
            }
        }
    }

    private var planStep: some View {
        TitledCard("Plan selection", icon: "list.bullet.rectangle") {
            VStack(spacing: 10) {
                ForEach(Plan.allCases) { p in
                    Button {
                        plan = p
                    } label: {
                        HStack(alignment: .top) {
                            Image(systemName: plan == p ? "largecircle.fill.circle" : "circle")
                                .foregroundStyle(Theme.color.primary)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(p.rawValue).font(.subheadline.weight(.semibold))
                                Text(p.blurb).font(.caption).foregroundStyle(Theme.color.textSecondary)
                            }
                            Spacer()
                        }
                        .padding(12)
                        .background(plan == p ? Theme.color.primary.opacity(0.08) : Theme.color.surfaceMuted)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var reviewStep: some View {
        TitledCard("Review & submit", icon: "checkmark.seal.fill") {
            VStack(alignment: .leading, spacing: 10) {
                reviewRow("Name", fullName.isEmpty ? "—" : fullName)
                reviewRow("Phone", phone.isEmpty ? "—" : phone)
                reviewRow("Address", addressSummary)
                reviewRow("Plan", plan.rawValue)
                Toggle("I confirm the information is accurate.", isOn: $agreed)
                    .font(.subheadline)
            }
        }
    }

    private var addressSummary: String {
        let parts = [street, city, state, zip].filter { !$0.isEmpty }
        return parts.isEmpty ? "—" : parts.joined(separator: ", ")
    }

    private func reviewRow(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.caption).foregroundStyle(Theme.color.textSecondary)
            Text(value).font(.subheadline.weight(.medium))
        }
    }

    private var navigationRow: some View {
        HStack {
            if step > 0 {
                Button("Back") { step -= 1 }
                    .buttonStyle(.bordered)
            }
            Spacer()
            if step < steps.count - 1 {
                Button("Continue") { step += 1 }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.color.primary)
                    .disabled(!canAdvance)
            } else {
                Button("Submit application") { showConfirmation = true }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.color.success)
                    .disabled(!canSubmit)
            }
        }
    }

    private var canAdvance: Bool {
        switch step {
        case 0: !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 1: !street.isEmpty && !city.isEmpty && !state.isEmpty && !zip.isEmpty
        case 2: true
        default: true
        }
    }

    private var canSubmit: Bool {
        let nameOk = !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let addrOk = !street.isEmpty && !city.isEmpty && !state.isEmpty && !zip.isEmpty
        return agreed && step == steps.count - 1 && nameOk && addrOk
    }

    private func labeledField<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption.weight(.semibold))
            content()
        }
    }

    private func resetWizard() {
        step = 0
        fullName = ""
        phone = ""
        street = ""
        city = ""
        state = ""
        zip = ""
        plan = .standard
        agreed = false
    }
}

#Preview {
    NavigationStack {
        EnrollmentView()
    }
}
