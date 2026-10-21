import SwiftUI

/// Owner: Dev B. Call EventRepository.approvedFeed(); push EventDetailView.
struct FeedView: View {
    var body: some View {
        ContentUnavailableView(
            "Campus feed",
            systemImage: "list.bullet.rectangle",
            description: Text("Dev B: list approved events only.")
        )
        .navigationTitle("Feed")
    }
}
