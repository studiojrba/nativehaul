import SwiftUI

/// Marks a real control as a tour hotspot (ADR 0040). While its step is showing it glows with a soft pulsing ring
/// (still under Reduce Motion), and using it moves the tour on.
struct GuideHotspotModifier: ViewModifier {
    /// Which hotspot this is.
    let hotspot: GuideHotspot
    @Environment(\.onboardingGuide) private var guide
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isBright = true

    func body(content: Content) -> some View {
        let isActive = guide?.currentStep?.hotspot == hotspot
        content
            .overlay {
                if isActive {
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.lg, style: .continuous)
                        .strokeBorder(Theme.accent, lineWidth: DesignTokens.Guide.ringWidth)
                        .padding(DesignTokens.Guide.ringInset)
                        .shadow(color: Theme.accent, radius: DesignTokens.Guide.glowRadius)
                        .opacity(isBright || reduceMotion ? 1 : DesignTokens.Guide.pulseLow)
                        .allowsHitTesting(false)
                        .onAppear { pulse() }
                }
            }
            .simultaneousGesture(TapGesture().onEnded { guide?.didUse(hotspot) })
    }

    private func pulse() {
        guard !reduceMotion else { return }
        withAnimation(.easeInOut(duration: DesignTokens.Guide.pulseHalfSeconds).repeatForever()) { isBright = false }
    }
}

extension View {
    /// Makes this control a tour hotspot.
    func guideHotspot(_ hotspot: GuideHotspot) -> some View {
        modifier(GuideHotspotModifier(hotspot: hotspot))
    }
}
