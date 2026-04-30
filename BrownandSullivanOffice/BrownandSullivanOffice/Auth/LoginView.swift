import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var app: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false
    @State private var error: String?

    @FocusState private var focused: Field?
    private enum Field { case email, password }

    var body: some View {
        ZStack {
            Theme.gradient.loginBg.ignoresSafeArea()

            // Subtle dotted overlay (matches the SVG background pattern from globals.css)
            Color.white.opacity(0.03).ignoresSafeArea()

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
                .tint(Theme.color.primary)
            }
        }
    }

    private var bubble: some View {
        VStack(spacing: Theme.spacing.l) {
            // Header
            VStack(spacing: 6) {
                Image(systemName: "building.2.crop.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Theme.gradient.primary)
                Text("Welcome Back")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color(hex: 0x1A365D))
                Text("Sign in to continue to your office")
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: 0x4A5568))
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

            // Form
            VStack(alignment: .leading, spacing: Theme.spacing.m) {
                fieldLabel("Email address")
                TextField("Enter your email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .focused($focused, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { focused = .password }
                    .modifier(LoginField())

                fieldLabel("Password")
                SecureField("Enter your password", text: $password)
                    .focused($focused, equals: .password)
                    .submitLabel(.go)
                    .onSubmit(submit)
                    .modifier(LoginField())

                Toggle(isOn: $rememberMe) {
                    Text("Remember me").font(.subheadline)
                }
                .tint(Color(hex: 0x4299E1))
                .padding(.top, 4)
            }

            Button(action: submit) {
                Text("Sign In")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
            .background(Theme.gradient.primary)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: Color(hex: 0x4299E1).opacity(0.3), radius: 12, y: 4)
        }
        .padding(Theme.spacing.xl)
        .background(Color.white.opacity(0.96))
        .clipShape(RoundedRectangle(cornerRadius: Theme.radius.xl, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radius.xl, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 50, x: 0, y: 25)
        .frame(maxWidth: 460)
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color(hex: 0x2D3748))
    }

    private func submit() {
        if app.signIn(email: email, password: password) {
            error = nil
        } else {
            error = "Please enter both email and password"
        }
    }
}

private struct LoginField: ViewModifier {
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
        LoginView().environmentObject(AppState())
    }
}
