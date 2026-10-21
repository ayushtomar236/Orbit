import SwiftUI

/// Owner: Dev C. Not implemented in foundation.
struct CreateEventView: View {
    var body: some View {
        OrbitPlaceholder(
            title: "Create event",
            systemImage: "plus.circle",
            message: "Dev C: EventRepository.create(_:posterJPEG:). Path {userId}/{eventId}.jpg (lowercase UUIDs)."
        )
        .navigationTitle("Create")
    }
}
