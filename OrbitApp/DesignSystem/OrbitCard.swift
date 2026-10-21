import SwiftUI

struct OrbitCard<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(OrbitSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(OrbitColors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: OrbitRadius.card, style: .continuous))
    }
}
