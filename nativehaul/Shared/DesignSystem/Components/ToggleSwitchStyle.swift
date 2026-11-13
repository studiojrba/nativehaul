import SwiftUI

/// The shared switch (spec §3.5): a 56×32 track, `ink` 12% off and accent on (glowing at night), with a 24pt `knob`
/// that slides 24pt. Colour changes over 500ms; the knob moves on the house easing. Hovering an off switch darkens the
/// track and nudges the knob.
struct ToggleSwitchStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            configuration.label
            Spacer(minLength: 0)
            ToggleSwitchTrack(isOn: configuration.$isOn)
        }
    }
}

#Preview {
    @Previewable @State var isOn = true
    @Previewable @State var isOff = false
    AppearancePreviewPair {
        VStack(spacing: DesignTokens.Spacing.lg) {
            Toggle("Music", isOn: $isOn)
            Toggle("Interface sounds", isOn: $isOff)
        }
        .toggleStyle(ToggleSwitchStyle())
        .font(Typeface.sans(TypeStyle.Size.label, weight: .medium))
        .foregroundStyle(Theme.ink)
        .frame(width: DesignTokens.Layout.formLabelWidth * 2)
        .padding(DesignTokens.Spacing.xl)
    }
}
