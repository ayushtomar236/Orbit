import SwiftUI

/// Owner: Dev A. Wire to AuthRepository. Sign-up lives in SignUpView.
struct SignInView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Sign in",
                systemImage: "person.crop.circle.badge.plus",
                description: Text("Dev A: implement email/password against AuthRepository.")
            )
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    NavigationLink("Create account") {
                        SignUpView()
                    }
                }
            }
        }
    }
}
