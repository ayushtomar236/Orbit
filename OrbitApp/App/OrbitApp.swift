import SwiftUI

@main
struct OrbitApp: App {
    @State private var environment = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            AuthGate()
                .environment(environment)
        }
    }
}
