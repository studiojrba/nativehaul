import SwiftUI

// Screen metrics are token source (spec §3.0–§3.2, §4.1), so the magic-number rule is off here.
// swiftlint:disable no_magic_numbers

extension ShellLayout {
    /// Space the floating chrome takes, which pages keep clear of.
    enum Chrome {
        /// Leading space that clears the nav island (also where the hero's left chevron sits).
        static let islandClearance: CGFloat = 100
        /// Top space that clears the top bar.
        static let topBarClearance: CGFloat = 76
        /// Gap between the top bar's pills.
        static let pillGap: CGFloat = 16
        /// Horizontal padding inside the top bar's pills.
        static let pillPadding: CGFloat = 16
        /// The couch pill's trailing padding (around the switch).
        static let couchTrailingPadding: CGFloat = 6
        /// Gap inside the search and couch pills.
        static let innerGap: CGFloat = 12
        /// Couch pill TV icon.
        static let couchIcon: CGFloat = 16
        /// Search clear (×) icon.
        static let clearIcon: CGFloat = 15
        /// `⌘K` chip padding.
        static let kbdHorizontal: CGFloat = 6
        /// `⌘K` chip vertical padding.
        static let kbdVertical: CGFloat = 2
        /// Result row padding.
        static let resultPadding: CGFloat = 8
        /// Result row radius.
        static let resultRadius: CGFloat = 16
        /// Hovered result row: `surface` at this opacity.
        static let resultHoverOpacity: Double = 0.70
        /// Empty-results padding.
        static let emptyHorizontal: CGFloat = 16
        /// Empty-results vertical padding.
        static let emptyVertical: CGFloat = 20
        /// Tooltip gap from the island.
        static let tooltipGap: CGFloat = 12
        /// Gap between nav buttons.
        static let navGap: CGFloat = 6
        /// Nav icon weight when active (stroke 2.1 in the design).
        static let activeIconWeight = Font.Weight.semibold
        /// Nav icon weight when inactive (stroke 1.7).
        static let inactiveIconWeight = Font.Weight.regular
        /// Back pill: `surface` fill opacity.
        static let backFillOpacity: Double = 0.60
        /// Back pill arrow.
        static let backArrow: CGFloat = 14
        /// Real window buttons: their size, as macOS draws them.
        static let trafficLightSize: CGFloat = 14
        /// Real window buttons: distance between their left edges.
        static let trafficLightPitch: CGFloat = 20
        /// Reserved width for the three window buttons inside the left pill.
        static let trafficLightsWidth: CGFloat = trafficLightSize + trafficLightPitch * 2
    }

    /// The Home hero (spec §3.1, §4.1).
    enum Hero {
        /// Minimum height as a share of the window (`86vh`).
        static let minHeightShare: CGFloat = 0.86
        /// Left column share (`1.15fr / 1fr`).
        static let textColumnShare: CGFloat = 1.15 / 2.15
        /// Gap between the columns.
        static let columnGap: CGFloat = 40
        /// Top padding.
        static let topPadding: CGFloat = 96
        /// Eyebrow to headline.
        static let headlineTop: CGFloat = 24
        /// Headline to progress line.
        static let progressTop: CGFloat = 28
        /// Progress line maximum width.
        static let progressMaxWidth: CGFloat = 480
        /// Progress line to actions.
        static let actionsTop: CGFloat = 40
        /// Gap between the actions.
        static let actionsGap: CGFloat = 12
        /// Actions to dots.
        static let dotsTop: CGFloat = 32
        /// Padding around each dot (its hit area); the row is pulled back by the same amount so the first dot aligns.
        static let dotHitPadding: CGFloat = 6
        /// The case's maximum width.
        static let caseMaxWidth: CGFloat = 340
        /// Left chevron's leading position (clears the nav island).
        static let chevronLeading: CGFloat = 100
        /// Right chevron's trailing position.
        static let chevronTrailing: CGFloat = 16
        /// Chevrons sit this far below the section's middle.
        static let chevronDrop: CGFloat = 48
        /// Headline letter spacing (em).
        static let headlineTrackingEm: CGFloat = -0.01
        /// Most slides in the carousel.
        static let maximumSlides = 8
        /// "About the game" arrow size.
        static let arrowSize: CGFloat = 16
        /// Gap between "About the game" and its arrow.
        static let arrowGap: CGFloat = 8
        /// Gap between Play's icon and label.
        static let playGap: CGFloat = 12
    }

    /// The standing case (spec §4.1 `HeroCase`).
    enum StandingCase {
        /// Width-to-height of a physical game case face (105 × 170 mm).
        static let aspectRatio: CGFloat = 105.0 / 170.0
        /// Outer corner radius.
        static let radius: CGFloat = 6
        /// Floor shadow height.
        static let floorHeight: CGFloat = 40
        /// Floor shadow blur radius (CSS `blur-2xl`, 40px).
        static let floorBlur: CGFloat = 20
        /// The case's own edge, a darker sliver of the game's palette that sells the depth.
        static let edgeWidthShare: CGFloat = 0.035
        /// The cover inset inside the case frame.
        static let coverInsetShare: CGFloat = 0.025
        /// Inner (cover) radius.
        static let coverRadius: CGFloat = 3
    }

    /// The Continue playing shelf (spec §3.1).
    enum Continue {
        /// Section top padding.
        static let sectionTop: CGFloat = 80
        /// Heading to shelf.
        static let shelfTop: CGFloat = 8
        /// Cards across at rest.
        static let cardsAcross = 3
        /// Gap between cards.
        static let gap: CGFloat = 28
        /// Tile aspect (4:3).
        static let aspectRatio: CGFloat = 4.0 / 3.0
        /// Tile radius.
        static let radius: CGFloat = 28
        /// Artwork scale on hover.
        static let hoverScale: CGFloat = 1.04
        /// Info bar inset from the tile.
        static let infoInset: CGFloat = 12
        /// Info bar radius.
        static let infoRadius: CGFloat = 16
        /// Info bar horizontal padding.
        static let infoHorizontal: CGFloat = 16
        /// Info bar vertical padding.
        static let infoVertical: CGFloat = 12
        /// Round play button.
        static let playSize: CGFloat = 40
        /// Play glyph.
        static let playIcon: CGFloat = 15
        /// Entrance stagger per card (seconds).
        static let stagger: Double = 0.09
        /// Left chevron's inset from the window edge.
        static let chevronLeading: CGFloat = 88
        /// Right chevron's inset from the window edge.
        static let chevronTrailing: CGFloat = 8
    }

    /// The whole-shelf card at the bottom of Home (spec §3.1).
    enum WholeShelf {
        /// Top padding.
        static let top: CGFloat = 64
        /// Card radius.
        static let radius: CGFloat = 32
        /// Horizontal padding.
        static let horizontal: CGFloat = 40
        /// Vertical padding.
        static let vertical: CGFloat = 36
        /// `cream` fill opacity.
        static let fillOpacity: Double = 0.70
        /// Round button size.
        static let buttonSize: CGFloat = 56
        /// Arrow size.
        static let arrowSize: CGFloat = 20
        /// Hover slide.
        static let hoverSlide: CGFloat = 4
        /// Title to line.
        static let lineTop: CGFloat = 8
    }

    /// Section headings (`SectionHead`, spec §3.1).
    enum SectionHead {
        /// Eyebrow to title.
        static let titleTop: CGFloat = 12
    }

    /// The Library page (spec §3.2).
    enum Library {
        /// Height of the background wash.
        static let washHeight: CGFloat = 620
        /// Top padding.
        static let topPadding: CGFloat = 144
        /// Gap between the title block and the sort control.
        static let headerGap: CGFloat = 32
        /// Eyebrow to title.
        static let titleTop: CGFloat = 16
        /// Title to subtitle.
        static let subtitleTop: CGFloat = 20
        /// Title size: minimum.
        static let titleMin: CGFloat = 64
        /// Title size: share of the window width.
        static let titleWidthShare: CGFloat = 0.08
        /// Title size: maximum.
        static let titleMax: CGFloat = 120
        /// Title line height.
        static let titleLineHeight: CGFloat = 0.9
        /// Header to grid.
        static let gridTop: CGFloat = 64
        /// Minimum card width.
        static let minimumCardWidth: CGFloat = 220
        /// Column gap.
        static let columnGap: CGFloat = 32
        /// Row gap.
        static let rowGap: CGFloat = 56
        /// Cover aspect (3:4).
        static let coverAspect: CGFloat = 3.0 / 4.0
        /// Badge inset from the cover's corner.
        static let badgeInset: CGFloat = 12
        /// Badge horizontal padding.
        static let badgeHorizontal: CGFloat = 12
        /// Badge vertical padding.
        static let badgeVertical: CGFloat = 4
        /// Cover to text.
        static let textTop: CGFloat = 16
        /// Gap between title and playtime.
        static let textGap: CGFloat = 12
        /// Entrance stagger per card (seconds).
        static let stagger: Double = 0.035
        /// Staggers stop growing after this many cards, so a big shelf still lands quickly.
        static let maximumStaggeredCards = 24
    }
}

// swiftlint:enable no_magic_numbers
