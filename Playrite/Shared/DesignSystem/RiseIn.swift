import SwiftUI

/// A gentle fade-and-rise entrance (ADR 0040): content settles into place, nothing snaps. Staggered by `order`, capped
/// so a long page never waits, and sub-second. Under Reduce Motion content simply appears.
struct RiseIn: ViewModifier {
    /// Position in the entrance sequence.
    let step: RiseStep
    @State private var isShown = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(isShown || reduceMotion ? 1 : 0)
            .offset(y: isShown || reduceMotion ? 0 : DesignTokens.Light.riseDistance)
            .onAppear {
                guard !reduceMotion else { return }
                let delay = Double(min(step.rawValue, DesignTokens.Light.riseMaxSteps)) * DesignTokens.Light.riseStagger
                withAnimation(.easeOut(duration: DesignTokens.Light.riseSeconds).delay(delay)) { isShown = true }
            }
    }
}

extension View {
    /// Fades and rises into place at `step` in the page's entrance.
    func riseIn(_ step: RiseStep = .first) -> some View {
        modifier(RiseIn(step: step))
    }
}
