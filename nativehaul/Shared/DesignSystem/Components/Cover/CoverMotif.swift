import SwiftUI

/// A drawn cover's motif (make-export-nov13 `Art.tsx`), picked per game by a stable hash of its title.
enum CoverMotif: String, CaseIterable, Sendable {
    /// A sun over banded water and dark hills.
    case sun
    /// A moon over rolling waves.
    case waves
    /// Mountains with snow caps.
    case peaks
    /// Concentric rings.
    case rings
    /// A planet, a tilted orbit and stars.
    case orbit
    /// Nested arches.
    case arches
    /// An eight-petal flower.
    case bloom
    /// Tilted stripes behind a disc.
    case stripes

    /// The motif for `title` (stable across launches).
    static func forTitle(_ title: String) -> CoverMotif {
        allCases[Int(CoverSeed.motifHash(title) % UInt64(allCases.count))]
    }
}
