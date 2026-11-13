import SwiftUI

/// The switch's drawing (spec §3.5): a 56×32 track — `ink` 12% off (15% hovered), accent on with a night glow — and a
/// 24pt knob inset 4pt that slides across, nudging 4pt toward on while hovered. Not interactive by itself: it is used
/// inside ``ToggleSwitchTrack`` and the top bar's Couch mode pill.
struct SwitchGraphic: View {
    /// Whether it reads as on.
    let isOn: Bool
    /// Whether its control is hovered.
    var isHovered = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
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

    private var trackOpacity: Double {
        isHovered ? KitMetrics.Switch.hoverOffOpacity : KitMetrics.Switch.offOpacity
    }
}

#Preview {
    AppearancePreviewPair {
        HStack(spacing: DesignTokens.Spacing.lg) {
            SwitchGraphic(isOn: false)
            SwitchGraphic(isOn: false, isHovered: true)
            SwitchGraphic(isOn: true)
        }
        .padding(DesignTokens.Spacing.xl)
    }
}
