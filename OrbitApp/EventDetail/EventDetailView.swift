import SwiftUI

/// Owner: Dev B (layout) / Dev C (register + save). Not implemented in foundation.
struct EventDetailView: View {
    let eventId: UUID

    var body: some View {
        OrbitPlaceholder(
            title: "Event",
            systemImage: "calendar",
            message: "Dev B: EventRepository.event(id:). Dev C: register/save. id=\(eventId.uuidString)"
        )
        .navigationTitle("Event")
    }
}
