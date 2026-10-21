import Foundation

struct Event: Codable, Identifiable, Sendable, Hashable {
    let id: UUID
    let organizerId: UUID
    let title: String
    let description: String
    let venue: String
    let startsAt: Date
    let endsAt: Date
    let posterPath: String?
    let status: EventStatus
    let createdAt: Date
    let updatedAt: Date
}
