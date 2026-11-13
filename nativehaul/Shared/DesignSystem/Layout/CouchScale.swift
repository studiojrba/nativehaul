import SwiftUI

/// Scales couch values (``CouchLayout``, designed at 1080 points tall) to the actual screen: 10-foot sizes follow the
/// screen height, so 1080p and 4K match. Also turns `vh`/`vw` shares into points and works out how many tiles fit.
struct CouchScale: Equatable, Sendable {
    /// The screen (window) size in points.
    let size: CGSize

    /// Height ÷ 1080 (1 when the size is unknown).
    var factor: CGFloat {
        size.height > 0 ? size.height / CouchLayout.referenceHeight : 1
    }

    /// A reference value at this screen's size.
    func callAsFunction(_ value: CGFloat) -> CGFloat {
        value * factor
    }

    /// A share of the screen height (`vh`).
    func height(_ share: CGFloat) -> CGFloat {
        size.height * share
    }

    /// A share of the screen width (`vw`).
    func width(_ share: CGFloat) -> CGFloat {
        size.width * share
    }

    /// Tiles fully on screen between the gutters (spec §3.7 V = floor((W − 128 + 36) / 268), scaled); the next one
    /// peeks in. At least one.
    var visibleTiles: Int {
        let pitch = self(CouchLayout.Shelves.tileWidth + CouchLayout.Shelves.tileGap)
        let room = size.width - self(CouchLayout.gutter) * CouchLayout.gutterCount + self(CouchLayout.Shelves.tileGap)
        guard pitch > 0 else { return 1 }
        return max(1, Int((room / pitch).rounded(.down)))
    }

    /// `clamp(min, share·vh, max)` with the bounds scaled.
    func clamped(min lower: CGFloat, share: CGFloat, max upper: CGFloat) -> CGFloat {
        Swift.min(self(upper), Swift.max(self(lower), size.height * share))
    }
}
