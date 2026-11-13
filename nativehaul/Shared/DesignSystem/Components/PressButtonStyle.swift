import SwiftUI

/// A plain button with the house press feedback and hand cursor (spec §4.3), for tappable cards and covers.
struct PressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .pressFeedback(isPressed: configuration.isPressed)
    }
}

#Preview {
    AppearancePreviewPair {
        Button {} label: {
            RoundedRectangle(cornerRadius: KitMetrics.Radius.cover, style: .continuous)
                .fill(Theme.cream)
                .frame(width: DesignTokens.Cover.stripWidth, height: DesignTokens.Cover.stripWidth)
                .elevation(.regular)
        }
        .buttonStyle(PressButtonStyle())
        .padding(KitMetrics.Spacing.section)
    }
}
