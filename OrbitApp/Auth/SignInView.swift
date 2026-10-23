import SwiftUI

struct SignInView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isSubmitting = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: OrbitSpacing.sm) {
                        Text("Welcome to Orbit")
                            .font(.largeTitle.bold())
                        Text("Find the events happening around your campus.")
                            .foregroundStyle(OrbitColors.secondaryText)
                    }
                    .padding(.vertical, OrbitSpacing.sm)
                    .listRowSeparator(.hidden)
                }

                Section("Account") {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                }

                if let errorMessage {
                    Section {
                        Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                            .foregroundStyle(OrbitColors.danger)
                            .font(.footnote)
                    }
                }

                Section {
                    OrbitButton(title: isSubmitting ? "Signing in…" : "Sign in", enabled: canSubmit) {
                        Task { await signIn() }
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
            .scrollContentBackground(.hidden)
            .background(OrbitColors.background)
            .navigationTitle("Sign in")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink("Create account") { SignUpView() }
                        .disabled(isSubmitting)
                }
            }
            .onChange(of: email) { _, _ in errorMessage = nil }
            .onChange(of: password) { _, _ in errorMessage = nil }
        }
    }

    private var canSubmit: Bool {
        !isSubmitting && !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !password.isEmpty
    }

    @MainActor
    private func signIn() async {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard Self.isValidEmail(cleanEmail) else {
            errorMessage = "Enter a valid email address."
            return
        }
        guard !password.isEmpty else {
            errorMessage = "Enter your password."
            return
        }

        isSubmitting = true
        defer { isSubmitting = false }
        do {
            try await environment.auth.signIn(email: cleanEmail, password: password)
            try await environment.signedIn()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    static func isValidEmail(_ email: String) -> Bool {
        let parts = email.split(separator: "@", omittingEmptySubsequences: false)
        return parts.count == 2 && !parts[0].isEmpty && parts[1].contains(".")
    }
}
