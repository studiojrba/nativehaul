import SwiftUI

/// A bubble's `rise`, once, on mount only (spec §4.4) — or nothing for page 1's hidden size reservation.
struct BubbleEntrance: ViewModifier {
    /// Skip the entrance.
    let isStill: Bool

    func body(content: Content) -> some View {
        if isStill {
            content
        } else {
            content.riseIn()
        }
    }
}
