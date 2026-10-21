import SwiftUI

/// Owner: Dev B for layout. Register/save buttons call EventRepository (Dev C writes).
struct EventDetailView: View {
    let eventId: UUID

    var body: some View {
        ContentUnavailableView(
            "Event",
            systemImage: "calendar",
            description: Text("Dev B: load EventRepository.event(id: \(eventId.uuidString)). Dev C: register/save.")
        )
        .navigationTitle("Event")
    }
}
