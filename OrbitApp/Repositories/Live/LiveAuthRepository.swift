import Foundation
import Supabase

struct LiveAuthRepository: AuthRepository {
    let client: SupabaseClient

    func signIn(email: String, password: String) async throws {
        do {
            try await client.auth.signIn(email: email, password: password)
        } catch {
            throw Self.authError(from: error)
        }
    }

    func signUp(fullName: String, email: String, password: String) async throws -> SignUpResult {
        do {
            let response = try await client.auth.signUp(
                email: email,
                password: password,
                data: ["full_name": .string(fullName)]
            )
            switch response {
            case .session:
                return .signedIn
            case .user(let user):
                // Supabase intentionally returns an empty identities array for duplicate
                // addresses when email confirmation is enabled, to limit account enumeration.
                if user.identities?.isEmpty == true {
                    return .accountAlreadyExists
                }
                return .confirmationRequired
            }
        } catch {
            throw Self.authError(from: error)
        }
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }

    func hasSession() async throws -> Bool {
        do {
            _ = try await client.auth.session
            return true
        } catch {
            return false
        }
    }

    func sessionChanges() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            let task = Task {
                for await (_, session) in client.auth.authStateChanges {
                    continuation.yield(session != nil)
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    var currentUserId: UUID? {
        get async {
            try? await client.auth.session.user.id
        }
    }

    private static func authError(from error: Error) -> OrbitError {
        let message = error.localizedDescription
        let normalized = message.lowercased()
        if let urlError = error as? URLError,
           [.notConnectedToInternet, .networkConnectionLost, .timedOut, .cannotFindHost, .cannotConnectToHost]
            .contains(urlError.code) {
            return .network("Couldn’t reach Orbit’s sign-in service. Check your connection and try again.")
        }
        if normalized.contains("invalid login credentials") || normalized.contains("invalid email or password") {
            return .auth("That email and password combination wasn’t recognized.")
        }
        if normalized.contains("already registered") || normalized.contains("user already exists") {
            return .auth("An account with this email already exists. Try signing in instead.")
        }
        if normalized.contains("email not confirmed") {
            return .auth("Confirm your email using the link we sent before signing in.")
        }
        if normalized.contains("network") || normalized.contains("offline") || normalized.contains("timed out") {
            return .network("Couldn’t reach Orbit’s sign-in service. Check your connection and try again.")
        }
        return .auth(message)
    }
}
