import Foundation
import Observation

@Observable
@MainActor
final class EventDetailViewModel {
    private let events: EventRepository
    let eventId: UUID

    private(set) var item: EventWithMeta?
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var isNotFound = false

    init(eventId: UUID, events: EventRepository) {
        self.eventId = eventId
        self.events = events
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        isNotFound = false
        do {
            item = try await events.event(id: eventId)
        } catch {
            item = nil
            let message = error.localizedDescription
            errorMessage = message
            isNotFound = message == "Event not found."
        }
        isLoading = false
    }
}
