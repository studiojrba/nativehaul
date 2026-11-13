import SwiftUI

// Layout constants are token source (spec §3.7), so the magic-number rule is off here.
// swiftlint:disable no_magic_numbers

/// Couch mode's 10-foot geometry (spec §3.7, §2, ADR 0058). Every value is in points **at a 1080-point-tall screen**;
/// views multiply by ``CouchScale`` (screen height ÷ 1080), so 1080p and 4K look the same from the sofa. Values with
/// `Share` are fractions of the screen's height (`vh`) or width (`vw`), as named.
enum CouchLayout {
    /// The screen height every couch value is designed at.
    static let referenceHeight: CGFloat = 1080
    /// The side gutter (shelves, header, hero all start here; the arrows sit outside it).
    static let gutter: CGFloat = 64
    /// Gutters across the screen (left and right).
    static let gutterCount: CGFloat = 2
    /// A 1080p screen, for previews.
    static let previewScreen = CGSize(width: 1920, height: 1080)
    /// Half of it, for compact previews.
    static let previewHalf = CGSize(width: 960, height: 540)

    /// The header: wordmark and status pill.
    enum Header {
        /// Top padding.
        static let top: CGFloat = 40
        /// Wordmark size (semibold).
        static let wordmark: CGFloat = 26
        /// Status pill text.
        static let pillText: CGFloat = 22
        /// Status pill horizontal padding.
        static let pillHorizontal: CGFloat = 24
        /// Status pill vertical padding.
        static let pillVertical: CGFloat = 12
        /// Gap inside the pill.
        static let pillGap: CGFloat = 16
        /// The connection dot.
        static let dot: CGFloat = 10
    }

    /// The hero zone.
    enum Hero {
        /// Top of the text block (`13vh`).
        static let topShare: CGFloat = 0.13
        /// Width of the text block (`50vw`).
        static let widthShare: CGFloat = 0.50
        /// Eyebrow size.
        static let eyebrow: CGFloat = 20
        /// Headline: `clamp(40px, 5.6vh, 80px)`.
        static let headlineMin: CGFloat = 40
        /// See ``headlineMin``.
        static let headlineShare: CGFloat = 0.056
        /// See ``headlineMin``.
        static let headlineMax: CGFloat = 80
        /// Headline line height.
        static let headlineLineHeight: CGFloat = 0.95
        /// Progress line: `clamp(18px, 2.2vh, 24px)`.
        static let progressMin: CGFloat = 18
        /// See ``progressMin``.
        static let progressShare: CGFloat = 0.022
        /// See ``progressMin``.
        static let progressMax: CGFloat = 24
        /// Progress line max width.
        static let progressMaxWidth: CGFloat = 736
        /// Eyebrow → headline.
        static let headlineTop: CGFloat = 12
        /// Headline → progress.
        static let progressTop: CGFloat = 16
        /// Progress → prompt cluster.
        static let clusterTop: CGFloat = 20
        /// Gap between the cluster's parts.
        static let clusterGap: CGFloat = 36
        /// Cluster text size.
        static let clusterText: CGFloat = 20
        /// The cluster's opacity when focus is elsewhere.
        static let dimmedOpacity: Double = 0.4
        /// Case: distance from the right edge (`11vw`).
        static let caseRightShare: CGFloat = 0.11
        /// Case: top (`15vh`).
        static let caseTopShare: CGFloat = 0.15
        /// Case width (`16.5vh`).
        static let caseWidthShare: CGFloat = 0.165
        /// Arrow glyph size.
        static let arrowSize: CGFloat = 40
        /// Arrow distance from the screen edge.
        static let arrowInset: CGFloat = 4
        /// Arrow top (`28vh`).
        static let arrowTopShare: CGFloat = 0.28
        /// Inactive dot.
        static let dot: CGFloat = 10
        /// Active dot width.
        static let activeDot: CGFloat = 40
        /// Gap between dots.
        static let dotGap: CGFloat = 12
    }

    /// The shelves viewport and shelf rows.
    enum Shelves {
        /// Viewport top (`48vh`)…
        static let topShare: CGFloat = 0.48
        /// …minus this.
        static let topLift: CGFloat = 24
        /// Top fade: transparent to opaque over this.
        static let topFade: CGFloat = 24
        /// Bottom fade starts this far above the bottom…
        static let bottomFadeStart: CGFloat = 150
        /// …and is fully transparent this far above it.
        static let bottomFadeEnd: CGFloat = 36
        /// One shelf row; moving down shifts the stack by this.
        static let rowHeight: CGFloat = 400
        /// Rows below the focused one.
        static let belowOpacity: Double = 0.45
        /// Shelf title size (medium).
        static let title: CGFloat = 24
        /// Title → tiles.
        static let tilesTop: CGFloat = 24
        /// Vertical padding around the tiles (room for focus scale and ring).
        static let tilesVertical: CGFloat = 24
        /// Tile width.
        static let tileWidth: CGFloat = 232
        /// Gap between tiles.
        static let tileGap: CGFloat = 36
        /// Arrow glyph size.
        static let arrowSize: CGFloat = 44
        /// Arrow centre from the shelf's top (36 title + 48 gaps + 155 half-tile).
        static let arrowCenter: CGFloat = 239
        /// The band the arrows centre in (twice ``arrowCenter``).
        static let arrowBand: CGFloat = arrowCenter * 2
    }

    /// A couch tile (shelves, Library).
    enum Tile {
        /// Cover aspect (3:4).
        static let aspect: CGFloat = 3.0 / 4.0
        /// Corner radius.
        static let radius: CGFloat = 28
        /// Placeholder title size.
        static let title: CGFloat = 26
        /// Focused scale (from the bottom centre).
        static let focusScale: CGFloat = 1.14
        /// Focus ring width.
        static let ringWidth: CGFloat = 5
        /// Focus ring offset.
        static let ringOffset: CGFloat = 6
    }

    /// The prompt bar.
    enum PromptBar {
        /// Inset from each side.
        static let side: CGFloat = 48
        /// Distance from the bottom.
        static let bottom: CGFloat = 32
        /// Horizontal padding.
        static let horizontal: CGFloat = 40
        /// Vertical padding.
        static let vertical: CGFloat = 20
        /// Gap between prompts.
        static let gap: CGFloat = 36
        /// Label size.
        static let label: CGFloat = 20
        /// Glyph → label.
        static let labelGap: CGFloat = 8
        /// Between two glyphs of one prompt.
        static let glyphGap: CGFloat = 4
        /// Round glyph diameter.
        static let glyph: CGFloat = 40
        /// Wide glyph width.
        static let wideGlyph: CGFloat = 56
        /// Wide glyph corner radius.
        static let wideRadius: CGFloat = 12
        /// Glyph text size (semibold).
        static let glyphText: CGFloat = 16
    }

    /// Toasts.
    enum Toast {
        /// Letter size (display).
        static let letter: CGFloat = 120
        /// Message size.
        static let message: CGFloat = 32
        /// Corner radius.
        static let radius: CGFloat = 40
        /// Horizontal padding.
        static let horizontal: CGFloat = 40
        /// Vertical padding.
        static let vertical: CGFloat = 32
        /// Minimum width.
        static let minWidth: CGFloat = 160
    }
}

// swiftlint:enable no_magic_numbers
