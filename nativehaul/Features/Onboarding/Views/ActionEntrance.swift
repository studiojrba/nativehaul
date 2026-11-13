import SwiftUI

/// An action's entrance: `rise` staggered by index in the split screens, a plain `fade` on page 1 (spec §3.6).
struct ActionEntrance: ViewModifier {
    /// Page 1.
    let isWelcome: Bool
    /// Stagger delay.
    let delay: Double

    @State private var isShown = false

    func body(content: Content) -> some View {
        if isWelcome {
            content
                .opacity(isShown ? 1 : 0)
                .onAppear { withAnimation(Motion.fade) { isShown = true } }
        } else {
            content.riseIn(delay: delay)
        }
    }
}
