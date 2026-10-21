import Foundation

struct EventWithMeta: Identifiable, Sendable, Hashable {
    let event: Event
    let organizerName: String
    let isRegistered: Bool
    let isSaved: Bool
    let posterURL: URL?

    var id: UUID { event.id }
}
