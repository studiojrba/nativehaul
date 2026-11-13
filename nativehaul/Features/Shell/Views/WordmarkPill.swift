import SwiftUI

/// The top bar's left pill (spec §3.0): the "nativehaul" wordmark, 14pt semibold. The design's three decorative dots
/// are not drawn: the window's real buttons sit in the space reserved at the pill's start (``WindowChromeView``).
struct WordmarkPill: View {
    var body: some View {
        HStack(spacing: ShellLayout.TopBar.wordmarkGap) {
            Color.clear
                .frame(width: ShellLayout.Chrome.trafficLightsWidth, height: ShellLayout.Chrome.trafficLightSize)
            Text("nativehaul")
                .font(Typeface.sans(TypeStyle.Size.body, weight: .semibold))
                .foregroundStyle(Theme.ink)
        }
        .padding(.horizontal, ShellLayout.Chrome.pillPadding)
        .frame(height: ShellLayout.TopBar.pillHeight)
        .frostedGlass()
        .elevation(.small)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    AppearancePreviewPair {
        WordmarkPill().padding(DesignTokens.Spacing.xl)
    }
}
