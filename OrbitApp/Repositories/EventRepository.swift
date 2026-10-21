import Foundation

protocol EventRepository: Sendable {
    func approvedFeed() async throws -> [EventWithMeta]
    func event(id: UUID) async throws -> EventWithMeta
    func create(_ draft: EventDraft, posterJPEG: Data?) async throws -> Event
    func pendingForReview() async throws -> [Event]
    func setStatus(eventId: UUID, status: EventStatus) async throws
    func register(eventId: UUID) async throws
    func unregister(eventId: UUID) async throws
    func save(eventId: UUID) async throws
    func unsave(eventId: UUID) async throws
    func myRegistrations() async throws -> [Event]
    func mySaved() async throws -> [Event]
}
