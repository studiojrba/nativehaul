import SwiftUI

// Screen metrics are token source (spec §3.3), so the magic-number rule is off here.
// swiftlint:disable no_magic_numbers

extension ShellLayout {
    /// Game Detail (spec §3.3): a sticky visual column beside a scrolling column.
    enum Detail {
        /// Visual column share of the width (`1.08fr / 1fr`).
        static let visualShare: CGFloat = 1.08 / 2.08
        /// The scrolling column's top padding.
        static let columnTop: CGFloat = 112
        /// The scrolling column's side padding.
        static let columnSide: CGFloat = 64
        /// Side padding on wide windows (Tailwind `xl`, 1280pt and up).
        static let columnSideWide: CGFloat = 96
        /// Windows at least this wide use ``columnSideWide``.
        static let wideWindow: CGFloat = 1280
        /// The scrolling column's bottom padding.
        static let columnBottom: CGFloat = 128
        /// Back pill to eyebrow.
        static let eyebrowTop: CGFloat = 56
        /// Eyebrow to title.
        static let titleTop: CGFloat = 20
        /// Title size: minimum.
        static let titleMin: CGFloat = 56
        /// Title size: share of the window width.
        static let titleWidthShare: CGFloat = 0.062
        /// Title size: maximum.
        static let titleMax: CGFloat = 104
        /// Title line height.
        static let titleLineHeight: CGFloat = 0.92
        /// Title letter spacing (em).
        static let titleTrackingEm: CGFloat = -0.01
        /// Title to tagline.
        static let taglineTop: CGFloat = 24
        /// Tagline / title to description.
        static let descriptionTop: CGFloat = 32
        /// Description maximum width.
        static let descriptionMaxWidth: CGFloat = 544
        /// Description line spacing (17pt at line-height 1.75).
        static let descriptionLineSpacing: CGFloat = 12.75
        /// Description to the action row.
        static let actionsTop: CGFloat = 44
        /// Gap between actions.
        static let actionsGap: CGFloat = 12
        /// Favourite button size.
        static let favouriteSize: CGFloat = 56
        /// Favourite heart.
        static let heartSize: CGFloat = 18
        /// Show in Finder's folder icon.
        static let folderIcon: CGFloat = 16
        /// Action row to the build link and launch notes.
        static let linkTop: CGFloat = 20
        /// The build link's underline offset.
        static let underlineOffset: CGFloat = 4
        /// The build link's underline: `ink` at this opacity.
        static let underlineOpacity: Double = 0.20
        /// Action row / notes to the specs table.
        static let specsTop: CGFloat = 64
        /// Build link to the build log (Make `mt-6`).
        static let logTop: CGFloat = 24
        /// Spec row vertical padding.
        static let specRowVertical: CGFloat = 18
        /// Build status dot.
        static let statusDot: CGFloat = 8
        /// Gap between the dot and its text.
        static let statusGap: CGFloat = 8
        /// Space between sections further down.
        static let sectionTop: CGFloat = 96
        /// Section heading to content.
        static let sectionContentTop: CGFloat = 24
        /// Gap in the screenshots and related grids.
        static let gridGap: CGFloat = 20
        /// Wide screenshot aspect (16:9).
        static let wideShotAspect: CGFloat = 16.0 / 9.0
        /// Small screenshot aspect (4:3).
        static let smallShotAspect: CGFloat = 4.0 / 3.0
        /// Wide screenshot radius.
        static let wideShotRadius: CGFloat = 28
        /// Small screenshot radius.
        static let smallShotRadius: CGFloat = 24
        /// Editorial note `cream` opacity.
        static let noteFillOpacity: Double = 0.60
        /// Editorial note horizontal padding.
        static let noteHorizontal: CGFloat = 40
        /// Editorial note vertical padding.
        static let noteVertical: CGFloat = 48
        /// Quote line spacing (34pt at line-height 1.15).
        static let quoteLineSpacing: CGFloat = 5.1
        /// Quote to caption.
        static let noteCaptionTop: CGFloat = 20
        /// Related covers across.
        static let relatedCount = 3
        /// Related cover aspect (3:4).
        static let relatedAspect: CGFloat = 3.0 / 4.0
        /// Related cover radius.
        static let relatedRadius: CGFloat = 22
        /// Related cover to its title.
        static let relatedTitleTop: CGFloat = 12
        /// The visual column's case: leading padding.
        static let caseLeading: CGFloat = 64
        /// The visual column's case: top padding.
        static let caseTop: CGFloat = 40
        /// Caption leading position.
        static let captionLeading: CGFloat = 112
        /// Caption bottom position.
        static let captionBottom: CGFloat = 28
        /// Caption `ink` opacity.
        static let captionOpacity: Double = 0.40
        /// The wash's first lift behind the case.
        static let washLiftFirst: Double = 0.75
        /// The wash's last lift behind the case.
        static let washLiftLast: Double = 0.40
        /// The "More" section: gap between its parts.
        static let moreGap: CGFloat = 32
    }
}

// swiftlint:enable no_magic_numbers
