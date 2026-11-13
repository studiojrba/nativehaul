import SwiftUI

/// `float` (spec §2.8): a slow 6s bob, 0 → −10pt → 0, forever. Still under Reduce Motion.
struct FloatIdle: ViewModifier {
    @State private var isUp = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .offset(y: isUp && !reduceMotion ? Motion.floatTravel : 0)
            .onAppear {
                guard let animation = Motion.float(reduceMotion: reduceMotion) else { return }
                withAnimation(animation) { isUp = true }
            }
    }
}

extension View {
    /// Bobs gently, like an object resting on air.
    func floatIdle() -> some View {
        modifier(FloatIdle())
    }
}

#Preview {
    AppearancePreviewPair {
        RoundedRectangle(cornerRadius: KitMetrics.Radius.card, style: .continuous)
            .fill(Theme.cream)
            .frame(width: ShellLayout.LaunchOverlay.coverWidth, height: ShellLayout.LaunchOverlay.coverWidth)
            .elevation(.regular)
            .floatIdle()
            .padding(KitMetrics.Spacing.page)
    }
}
