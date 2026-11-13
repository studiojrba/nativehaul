import SwiftUI

/// One soft wash square floating behind page 1's mark (spec §3.6 logo cluster).
struct FloatingSquare: Sendable {
    /// Side length.
    let size: CGFloat
    /// Centre, as a share of the cluster.
    let center: UnitPoint
    /// Float start delay (seconds).
    let delay: Double
    /// Its wash.
    let slot: WashSlot
}
