import SwiftUI

/// The switch graphic, also usable on its own (the top bar's Couch mode pill).
struct ToggleSwitchTrack: View {
    /// The switch's state.
    @Binding var isOn: Bool

    @State private var isHovered = false
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button { isOn.toggle() } label: {
            Capsule()
                .fill(isOn ? Theme.accent : Theme.ink.opacity(trackOpacity))
                .frame(width: KitMetrics.Switch.track.width, height: KitMetrics.Switch.track.height)
                .accentGlow(isOn)
                .overlay(alignment: isOn ? .trailing : .leading) {
                    Circle()
                        .fill(Theme.knob)
                        .frame(width: KitMetrics.Switch.knob, height: KitMetrics.Switch.knob)
                        .elevation(.small)
                        .offset(x: !isOn && isHovered ? KitMetrics.Switch.hoverNudge : 0)
                        .padding(KitMetrics.Switch.inset)
                }
                .animation(reduceMotion ? nil : Motion.settle(), value: isOn)
                .animation(reduceMotion ? nil : Motion.settle(), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 && isEnabled }
        .pointerStyle(isEnabled ? .link : nil)
        .opacity(isEnabled ? 1 : DesignTokens.Opacity.disabled)
        .accessibilityAddTraits(.isToggle)
        .accessibilityValue(isOn ? "On" : "Off")
    }

    private var trackOpacity: Double {
        isHovered ? KitMetrics.Switch.hoverOffOpacity : KitMetrics.Switch.offOpacity
    }
}

#Preview {
    @Previewable @State var isOn = false
    AppearancePreviewPair {
        ToggleSwitchTrack(isOn: $isOn).padding(DesignTokens.Spacing.xl)
    }
}
