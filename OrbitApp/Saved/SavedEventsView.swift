import SwiftUI

/// Owner: Dev C. Not implemented in foundation.
struct SavedEventsView: View {
    var body: some View {
        OrbitPlaceholder(
            title: "Saved events",
            systemImage: "bookmark",
            message: "Dev C: EventRepository.mySaved()."
        )
        .navigationTitle("Saved")
    }
}
