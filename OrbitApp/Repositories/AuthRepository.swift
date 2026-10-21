import Foundation

protocol AuthRepository: Sendable {
    func signIn(email: String, password: String) async throws
    func signUp(fullName: String, email: String, password: String) async throws
    func signOut() async throws
    func hasSession() async throws -> Bool
    var currentUserId: UUID? { get async }
}
