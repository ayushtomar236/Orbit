import SwiftUI

/// Owner: Dev C (writes) / Dev B (list UI if split).
struct SavedEventsView: View {
    var body: some View {
        ContentUnavailableView(
            "Saved events",
            systemImage: "bookmark",
            description: Text("Use EventRepository.mySaved().")
        )
        .navigationTitle("Saved")
    }
}
