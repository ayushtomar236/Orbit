import SwiftUI

enum OrbitColors {
    static let accent = Color.indigo
    static let background = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let text = Color.primary
    static let secondaryText = Color.secondary
    static let danger = Color.red
}

enum OrbitSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

enum OrbitRadius {
    static let card: CGFloat = 12
    static let button: CGFloat = 10
}

enum OrbitType {
    static let title = Font.title2.weight(.semibold)
    static let headline = Font.headline
    static let body = Font.body
    static let caption = Font.caption
}
