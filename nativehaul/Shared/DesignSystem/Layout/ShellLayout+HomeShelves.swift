import SwiftUI

// Shelf metrics are token source (make-export-nov13 Home.tsx `Row`, 1:1), so the magic-number rule is off here.
// swiftlint:disable no_magic_numbers

extension ShellLayout {
    /// Home's curated shelves (note 14): Make's `Row` panel and cards.
    enum HomeShelves {
        /// Panel leading margin (`ml-24`).
        static let panelLeading: CGFloat = 96
        /// Panel trailing margin (`mr-6`).
        static let panelTrailing: CGFloat = 24
        /// Panel top margin (`mt-20`).
        static let panelTop: CGFloat = 80
        /// Panel radius (`rounded-[48px]`).
        static let panelRadius: CGFloat = 48
        /// Panel vertical padding (`py-16`).
        static let panelVertical: CGFloat = 64
        /// The wash's opacity.
        static let washOpacity: Double = 0.70
        /// The heading's minimum inset inside the panel (`max(32px, …)`).
        static let insetMinimum: CGFloat = 32
        /// Beyond this panel width the heading centres (`(100cqw - 1160px) / 2`).
        static let insetColumn: CGFloat = 1160
        /// Heading to cards (`mt-4` + `pt-8`).
        static let cardsTop: CGFloat = 48
        /// Card gap (`gap-7`).
        static let gap: CGFloat = 28
        /// Card width (`w-[210px]`).
        static let cardWidth: CGFloat = 210
        /// Cover radius (`rounded-[24px]`).
        static let coverRadius: CGFloat = 24
        /// The cover's title is set from this em size (`text-[22px]`).
        static let coverEm: CGFloat = 22
        /// Cover to name (`mt-4`).
        static let nameTop: CGFloat = 16
        /// Badge inset (`right-3 top-3`).
        static let badgeInset: CGFloat = 12
        /// Badge horizontal padding (`px-2.5`).
        static let badgeHorizontal: CGFloat = 10
        /// Badge vertical padding (`py-1`).
        static let badgeVertical: CGFloat = 4
        /// One Continue card is at most this wide (`min(760px, …)`).
        static let singleContinueMax: CGFloat = 760

        /// The heading inset inside a panel of `width`.
        static func inset(panelWidth width: CGFloat) -> CGFloat {
            max(insetMinimum, (width - insetColumn) / 2 + insetMinimum)
        }
    }
}

// swiftlint:enable no_magic_numbers
