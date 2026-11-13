import SwiftUI

/// `float` with a start delay and an optional slower cycle (spec §3.6 logo cluster: 6s, delays 0/1.2/2.1/0.6s; the
/// mark at 7s). Still under Reduce Motion.
struct DelayedFloat: ViewModifier {
    /// Seconds before it starts.
    let delay: Double
    /// One full cycle, in seconds.
    var duration = Motion.Duration.float

    private static let halves: Double = 2

    @State private var isUp = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .offset(y: isUp && !reduceMotion ? Motion.floatTravel : 0)
            .onAppear {
                guard !reduceMotion else { return }
                let bob = Animation.easeInOut(duration: duration / Self.halves).repeatForever(autoreverses: true)
                withAnimation(bob.delay(delay)) { isUp = true }
            }
    }
}
