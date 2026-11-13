import SwiftUI

/// Press feedback and the hand cursor (spec §4.3): hover lifts 2pt, pressing drops 1pt at 98% scale, both on the
/// 380ms house easing. Clickable things show the pointing hand; disabled ones keep the arrow.
struct PressFeedback: ViewModifier {
    /// Whether the control is being pressed.
    let isPressed: Bool

    @State private var isHovered = false
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? KitMetrics.Press.pressedScale : 1)
            .offset(y: offset)
            .animation(reduceMotion ? nil : Motion.press, value: isPressed)
            .animation(reduceMotion ? nil : Motion.press, value: isHovered)
            .onHover { isHovered = $0 && isEnabled }
            .pointerStyle(isEnabled ? .link : nil)
    }

    private var offset: CGFloat {
        if isPressed {
            return KitMetrics.Press.pressedDrop
        }
        return isHovered ? KitMetrics.Press.hoverLift : 0
    }
}

extension View {
    /// Adds press feedback and the hand cursor; pass the button configuration's `isPressed`.
    func pressFeedback(isPressed: Bool = false) -> some View {
        modifier(PressFeedback(isPressed: isPressed))
    }
}

#Preview {
    AppearancePreviewPair {
        Button("Hover or press me") {}
            .buttonStyle(PressButtonStyle())
            .padding(DesignTokens.Spacing.xxl)
    }
}
