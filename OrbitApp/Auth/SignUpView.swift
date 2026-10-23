import SwiftUI

struct SignUpView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(\.dismiss) private var dismiss
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var confirmationMessage: String?
    @State private var isSubmitting = false

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: OrbitSpacing.sm) {
                    Text("Create your account")
                        .font(.largeTitle.bold())
                    Text("Join your campus community and keep track of events.")
                        .foregroundStyle(OrbitColors.secondaryText)
                }
                .padding(.vertical, OrbitSpacing.sm)
                .listRowSeparator(.hidden)
            }

            Section("Your details") {
                TextField("Full name", text: $fullName)
                    .textContentType(.name)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                SecureField("Password (at least 8 characters)", text: $password)
                    .textContentType(.newPassword)
                SecureField("Confirm password", text: $confirmPassword)
                    .textContentType(.newPassword)
            }

            Section {
                Label("New accounts start as students. Roles are managed by Orbit administrators.", systemImage: "person.crop.circle")
                    .font(.footnote)
                    .foregroundStyle(OrbitColors.secondaryText)
            }

            if let confirmationMessage {
                Section {
                    Label(confirmationMessage, systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.footnote)
                    Button("Back to sign in") { dismiss() }
                }
            }

            if let errorMessage {
                Section {
                    Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                        .foregroundStyle(OrbitColors.danger)
                        .font(.footnote)
                }
            }

            Section {
                OrbitButton(title: isSubmitting ? "Creating account…" : "Create account", enabled: canSubmit) {
                    Task { await signUp() }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .scrollContentBackground(.hidden)
        .background(OrbitColors.background)
        .navigationTitle("Sign up")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: fullName) { _, _ in clearMessages() }
        .onChange(of: email) { _, _ in clearMessages() }
        .onChange(of: password) { _, _ in clearMessages() }
        .onChange(of: confirmPassword) { _, _ in clearMessages() }
    }

    private var canSubmit: Bool {
        !isSubmitting && !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !password.isEmpty && !confirmPassword.isEmpty
    }

    private func clearMessages() {
        errorMessage = nil
        confirmationMessage = nil
    }

    @MainActor
    private func signUp() async {
        let cleanName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty else {
            errorMessage = "Enter your full name."
            return
        }
        guard SignInView.isValidEmail(cleanEmail) else {
            errorMessage = "Enter a valid email address."
            return
        }
        guard password.count >= 8 else {
            errorMessage = "Choose a password with at least 8 characters."
            return
        }
        guard password == confirmPassword else {
            errorMessage = "Your passwords don’t match."
            return
        }

        isSubmitting = true
        defer { isSubmitting = false }
        do {
            switch try await environment.auth.signUp(fullName: cleanName, email: cleanEmail, password: password) {
            case .signedIn:
                try await environment.signedIn()
                dismiss()
            case .confirmationRequired:
                confirmationMessage = "Your account was created. Check your email for a confirmation link, then return here to sign in."
            case .accountAlreadyExists:
                errorMessage = "An account with this email already exists. Go back and sign in instead."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
