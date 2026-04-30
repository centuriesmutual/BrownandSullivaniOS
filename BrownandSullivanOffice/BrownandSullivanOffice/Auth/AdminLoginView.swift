import SwiftUI

/// Administrator sign-in — separate route from Office agents; opens `AdminView` on success.
struct AdminLoginView: View {
    @EnvironmentObject private var app: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false
    @State private var error: String?

    @FocusState private var focused: Field?
    private enum Field { case email, password }

    private let adminGradient = LinearGradient(
        colors: [Color(hex: 0xB91C1C), Color(hex: 0x7F1D1D)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    var body: some View {
        ZStack {
            Theme.Suite.chromeBackground.ignoresSafeArea()

            ScrollView {
                VStack {
                    Spacer(minLength: 40)
                    bubble
                    Spacer(minLength: 40)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, Theme.spacing.l)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    app.goToHub()
                } label: {
                    Label("Workspaces", systemImage: "chevron.backward")
                }
                .tint(Theme.color.danger)
            }
        }
    }

    private var bubble: some View {
        VStack(spacing: Theme.spacing.l) {
            VStack(spacing: 6) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 56))
                    .foregroundStyle(adminGradient)
                Text("Admin Console")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color(hex: 0x450A0A))
                Text("Sign in for system overview, users, and activity")
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: 0x57534E))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, Theme.spacing.l)

            if let error {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text(error).font(.footnote)
                    Spacer()
                }
                .padding(12)
                .background(Theme.color.danger.opacity(0.10))
                .foregroundStyle(Theme.color.danger)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            VStack(alignment: .leading, spacing: Theme.spacing.m) {
                fieldLabel("Admin email")
                TextField("admin@yourorg.com", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .focused($focused, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { focused = .password }
                    .modifier(AdminLoginField())

                fieldLabel("Password")
                SecureField("Enter your password", text: $password)
                    .focused($focused, equals: .password)
                    .submitLabel(.go)
                    .onSubmit(submit)
                    .modifier(AdminLoginField())

                Toggle(isOn: $rememberMe) {
                    Text("Remember me").font(.subheadline)
                }
                .tint(Theme.color.danger)
                .padding(.top, 4)
            }

            Button(action: submit) {
                Text("Sign in to Admin")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
            .background(adminGradient)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: Color(hex: 0xB91C1C).opacity(0.35), radius: 12, y: 4)
        }
        .padding(Theme.spacing.xl)
        .background(Color.white.opacity(0.96))
        .clipShape(RoundedRectangle(cornerRadius: Theme.radius.xl, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radius.xl, style: .continuous)
                .stroke(Theme.color.danger.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 40, x: 0, y: 20)
        .frame(maxWidth: 460)
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color(hex: 0x2D3748))
    }

    private func submit() {
        if app.signInAdmin(email: email, password: password) {
            error = nil
        } else {
            error = "Please enter both email and password"
        }
    }
}

private struct AdminLoginField: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.body)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Theme.color.border, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    NavigationStack {
        AdminLoginView().environmentObject(AppState())
    }
}
