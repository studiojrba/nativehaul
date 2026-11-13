import SwiftUI

/// The interactive switch: ``SwitchGraphic`` as a toggle button with the hand cursor.
struct ToggleSwitchTrack: View {
    /// The switch's state.
    @Binding var isOn: Bool

    @State private var isHovered = false
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        Button { isOn.toggle() } label: {
            SwitchGraphic(isOn: isOn, isHovered: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 && isEnabled }
        .pointerStyle(isEnabled ? .link : nil)
        .opacity(isEnabled ? 1 : DesignTokens.Opacity.disabled)
        .accessibilityAddTraits(.isToggle)
        .accessibilityValue(isOn ? "On" : "Off")
    }
}

#Preview {
    @Previewable @State var isOn = false
    AppearancePreviewPair {
        ToggleSwitchTrack(isOn: $isOn).padding(DesignTokens.Spacing.xl)
    }
}
