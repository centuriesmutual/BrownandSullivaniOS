import SwiftUI

/// Mirrors `src/app/auth/login/page.tsx` — PressBox sign-in on an indigo-tinted surface.
struct CampaignLoginView: View {
    @EnvironmentObject private var app: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false
    @State private var error: String?

    @FocusState private var focused: Field?
    private enum Field { case email, password }

    var body: some View {
        ZStack {
            PressBoxTheme.heroGradient.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 24)
                    card
                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 20)
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
                .tint(PressBoxTheme.indigo)
            }
        }
    }

    private var card: some View {
        VStack(spacing: 22) {
            VStack(spacing: 6) {
                Text("PressBox")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(PressBoxTheme.indigo)
                Text("Campaign & marketing workspace — sign in below")
                    .font(.subheadline)
                    .foregroundStyle(PressBoxTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if let error {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(Color(hex: 0xDC2626))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color(hex: 0xFEF2F2))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            VStack(alignment: .leading, spacing: 16) {
                labeledField(
                    title: "Email address",
                    systemImage: "envelope",
                    content: {
                        TextField("Enter your email", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .focused($focused, equals: .email)
                            .submitLabel(.next)
                            .onSubmit { focused = .password }
                    })
                labeledField(
                    title: "Password",
                    systemImage: "lock.fill",
                    content: {
                        SecureField("Enter your password", text: $password)
                            .focused($focused, equals: .password)
                            .submitLabel(.go)
                            .onSubmit(submit)
                    })
            }

            HStack {
                Toggle(isOn: $rememberMe) {
                    Text("Remember me").font(.subheadline)
                }
                .tint(PressBoxTheme.indigo)
                Spacer()
                Button("Forgot password?") {}
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(PressBoxTheme.indigo)
            }

            Button(action: submit) {
                Text("Sign in to Campaign")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(PressBoxTheme.indigo)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 8) {
                Text("Popular workspace")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(PressBoxTheme.textPrimary)
                Text("Editors and leads see trending highlights first. Use an address with editor, director, lead, creator, partner, popular, trending, or vip in the part before @, add +popular before @, or sign in with a @partners.pressbox.marketing account.")
                    .font(.caption2)
                    .foregroundStyle(PressBoxTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 4)

            HStack(spacing: 4) {
                Text("Don't have an account?").font(.footnote)
                Button("Sign up") {}
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(PressBoxTheme.indigo)
            }
        }
        .padding(24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 24, x: 0, y: 10)
    }

    private func labeledField<C: View>(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> C
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(PressBoxTheme.textPrimary)
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .foregroundStyle(PressBoxTheme.textSecondary)
                content()
            }
            .padding(12)
            .background(PressBoxTheme.background)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(PressBoxTheme.border, lineWidth: 1)
            )
        }
    }

    private func submit() {
        if app.signInCampaign(email: email, password: password) {
            error = nil
        } else {
            error = "Enter email and password."
        }
    }
}

#Preview {
    NavigationStack {
        CampaignLoginView().environmentObject(AppState())
    }
}
