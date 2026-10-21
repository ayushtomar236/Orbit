import Foundation
import Supabase

struct LiveAuthRepository: AuthRepository {
    let client: SupabaseClient

    func signIn(email: String, password: String) async throws {
        do {
            try await client.auth.signIn(email: email, password: password)
        } catch {
            throw OrbitError.auth(error.localizedDescription)
        }
    }

    func signUp(fullName: String, email: String, password: String) async throws {
        do {
            try await client.auth.signUp(
                email: email,
                password: password,
                data: ["full_name": .string(fullName)]
            )
        } catch {
            throw OrbitError.auth(error.localizedDescription)
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

    var currentUserId: UUID? {
        get async {
            try? await client.auth.session.user.id
        }
    }
}
