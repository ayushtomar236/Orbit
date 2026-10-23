import Foundation

protocol AuthRepository: Sendable {
    func signIn(email: String, password: String) async throws
    func signUp(fullName: String, email: String, password: String) async throws -> SignUpResult
    func signOut() async throws
    func hasSession() async throws -> Bool
    func sessionChanges() -> AsyncStream<Bool>
    var currentUserId: UUID? { get async }
}

enum SignUpResult: Sendable {
    case signedIn
    case confirmationRequired
    case accountAlreadyExists
}
