import SwiftUI

/// Owner: Dev C (or whoever finishes Auth first).
struct CreateEventView: View {
    var body: some View {
        ContentUnavailableView(
            "Create event",
            systemImage: "plus.circle",
            description: Text("EventRepository.create(_:posterJPEG:). Poster path {userId}/{eventId}.jpg")
        )
        .navigationTitle("Create")
    }
}
