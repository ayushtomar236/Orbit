import SwiftUI

/// Shared empty/unimplemented screen. Feature owners replace the body, not this component.
struct OrbitPlaceholder: View {
    let title: String
    let systemImage: String
    let message: String

    var body: some View {
        ContentUnavailableView(title, systemImage: systemImage, description: Text(message))
            .foregroundStyle(OrbitColors.text)
    }
}
