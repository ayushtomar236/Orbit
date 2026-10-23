import Foundation

struct UnconfiguredAuthRepository: AuthRepository {
    func signIn(email: String, password: String) async throws {
        throw Self.missingConfig
    }

    func signUp(fullName: String, email: String, password: String) async throws -> SignUpResult {
        throw Self.missingConfig
    }

    func signOut() async throws {}

    func hasSession() async throws -> Bool { false }

    func sessionChanges() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            continuation.yield(false)
            continuation.finish()
        }
    }

    var currentUserId: UUID? { get async { nil } }

    private static let missingConfig = OrbitError.unknown(
        "Set your full Supabase project URL and anon or publishable client key in Secrets.xcconfig. Never use a service_role or sb_secret key in the app."
    )
}

struct UnconfiguredProfileRepository: ProfileRepository {
    func currentProfile() async throws -> Profile {
        throw OrbitError.unknown("Supabase is not configured.")
    }
}

struct UnconfiguredEventRepository: EventRepository {
    func approvedFeed() async throws -> [EventWithMeta] { throw missing }
    func event(id: UUID) async throws -> EventWithMeta { throw missing }
    func create(_ draft: EventDraft, posterJPEG: Data?) async throws -> Event { throw missing }
    func pendingForReview() async throws -> [Event] { throw missing }
    func setStatus(eventId: UUID, status: EventStatus) async throws { throw missing }
    func register(eventId: UUID) async throws { throw missing }
    func unregister(eventId: UUID) async throws { throw missing }
    func save(eventId: UUID) async throws { throw missing }
    func unsave(eventId: UUID) async throws { throw missing }
    func myRegistrations() async throws -> [Event] { throw missing }
    func mySaved() async throws -> [Event] { throw missing }

    private var missing: OrbitError {
        .unknown("Supabase is not configured.")
    }
}
