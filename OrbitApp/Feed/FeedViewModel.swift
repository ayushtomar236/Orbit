import Foundation
import Observation

@Observable
@MainActor
final class FeedViewModel {
    private let events: EventRepository

    var query = ""
    private(set) var loaded: [EventWithMeta] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    init(events: EventRepository) {
        self.events = events
    }

    var visibleEvents: [EventWithMeta] {
        Self.filter(loaded, query: query)
    }

    var showsEmptyCampus: Bool {
        !isLoading && errorMessage == nil && loaded.isEmpty
    }

    var showsEmptySearch: Bool {
        !isLoading && errorMessage == nil && !loaded.isEmpty && visibleEvents.isEmpty
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            loaded = try await events.approvedFeed()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func detailEventId(at index: Int) -> UUID? {
        guard visibleEvents.indices.contains(index) else { return nil }
        return visibleEvents[index].id
    }

    static func filter(_ events: [EventWithMeta], query: String) -> [EventWithMeta] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return events }
        return events.filter { item in
            item.event.title.localizedStandardContains(trimmed)
                || item.event.venue.localizedStandardContains(trimmed)
                || item.organizerName.localizedStandardContains(trimmed)
        }
    }
}
