import SwiftUI

/// Semantic colours. Views reference roles (`Theme.accent`), never concrete colours.
enum Theme {
    static let accent: Color = .accentColor
    static let background: Color = .init(nsColor: .windowBackgroundColor)
    static let surface: Color = .init(nsColor: .controlBackgroundColor)
    static let placeholder: Color = .secondary.opacity(DesignTokens.Opacity.subtle)
    static let primaryText: Color = .primary
    static let secondaryText: Color = .secondary
    static let separator: Color = .init(nsColor: .separatorColor)
    static let success: Color = .green
    static let warning: Color = .orange
    static let danger: Color = .red
    static let info: Color = .blue
    static let estimate: Color = .purple
}
