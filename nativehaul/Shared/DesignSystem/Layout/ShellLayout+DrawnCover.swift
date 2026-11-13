import SwiftUI

// Drawn-cover metrics are token source (make-export-nov13 Art.tsx, 1:1), so the magic-number rule is off here.
// swiftlint:disable no_magic_numbers

extension ShellLayout {
    /// Drawn covers (Make `Cover`): the art box, its washes and the title block, in Make's units.
    enum DrawnCover {
        /// The art's view box (`viewBox="0 0 300 420"`).
        static let box = CGSize(width: 300, height: 420)
        /// The background runs from `deep` to `deep` mixed this far toward `mid`.
        static let groundMix: Double = 0.35
        /// The sheen: white at this opacity at its centre.
        static let sheen = RGBA(hex: 0xFFFFFF, alpha: 0.22)
        /// The sheen's centre, as a share of the box (`cx=0.3 cy=0.2`).
        static let sheenCenter = CGPoint(x: 0.3, y: 0.2)
        /// The sheen's radius, as a share of the box height (`r=0.9`; SwiftUI draws it round, Make draws it as the
        /// box's ellipse).
        static let sheenRadius: CGFloat = 0.9
        /// Title block inset, as a share of the cover's width (`p-[8%]`).
        static let insetShare: CGFloat = 0.08
        /// Studio line size in ems (`text-[0.55em]`).
        static let studioEm: CGFloat = 0.55
        /// Studio tracking in ems (`tracking-[0.18em]`).
        static let studioTrackingEm: CGFloat = 0.18
        /// Studio line opacity (`opacity-75`).
        static let studioOpacity: Double = 0.75
        /// Studio to title in ems (`mt-[0.2em]`).
        static let titleGapEm: CGFloat = 0.2
        /// Title size in ems (`text-[1.45em]`).
        static let titleEm: CGFloat = 1.45
    }
}

// swiftlint:enable no_magic_numbers
