import SwiftUI

/// A quiet text action inside a row ("Remove", "Use detected"): 13pt `ink-soft`, `ink` on hover, hand cursor.
struct QuietTextButton: View {
    /// The title.
    let title: String
    /// The action.
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(title, action: action)
            .buttonStyle(.plain)
            .font(Typeface.sans(TypeStyle.Size.small))
            .foregroundStyle(isHovered ? Theme.ink : Theme.inkSoft)
            .onHover { isHovered = $0 }
            .pointerStyle(.link)
    }
}

#Preview {
    AppearancePreviewPair {
        QuietTextButton(title: "Remove") {}.padding(DesignTokens.Spacing.xl)
    }
}
