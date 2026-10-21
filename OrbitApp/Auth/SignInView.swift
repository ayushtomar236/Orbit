import SwiftUI

/// Owner: Dev A. Not implemented in foundation.
struct SignInView: View {
    var body: some View {
        NavigationStack {
            OrbitPlaceholder(
                title: "Sign in",
                systemImage: "person.crop.circle.badge.plus",
                message: "Dev A: email and password via AuthRepository.signIn, then AppEnvironment.signedIn()."
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
