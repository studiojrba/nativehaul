import SwiftUI

/// The 0.1.0 type scale (spec §2.7, §3): named sizes and ready-made fonts for both roles. Views use these, never a
/// literal size.
enum TypeStyle {
    /// UI text sizes (Geist).
    enum Size {
        /// Kbd chips, badges.
        static let micro: CGFloat = 11
        /// Captions, eyebrows, tooltips.
        static let caption: CGFloat = 12
        /// Secondary lines, segmented controls, pills.
        static let small: CGFloat = 13
        /// Search field, wordmark, rows.
        static let body: CGFloat = 14
        /// Card titles, button labels.
        static let label: CGFloat = 15
        /// Chat bubbles, launch sub.
        static let callout: CGFloat = 16
        /// Hero progress line, page intros.
        static let lead: CGFloat = 17
        /// Onboarding names, "Sure, let's go".
        static let large: CGFloat = 18
    }

    /// Display sizes (Instrument Serif).
    enum DisplaySize {
        /// Detail tagline (italic) and box-art tagline.
        static let tagline: CGFloat = 28
        /// Settings group titles.
        static let group: CGFloat = 32
        /// Editorial quote.
        static let quote: CGFloat = 34
        /// "Here we go…", "The whole shelf".
        static let card: CGFloat = 44
        /// Section titles (`SectionHead`).
        static let section: CGFloat = 52
        /// Onboarding wordmark.
        static let wordmark: CGFloat = 56
        /// Builds page title.
        static let page: CGFloat = 64
        /// Smallest hero headline (`clamp(56px, 7.4vw, 112px)`).
        static let heroMin: CGFloat = 56
        /// Largest hero headline.
        static let heroMax: CGFloat = 112
        /// Hero headline share of the window width.
        static let heroWidthShare: CGFloat = 0.074
        /// Line height of hero headlines, as a multiple of the size.
        static let heroLineHeight: CGFloat = 0.92
        /// Line height of section titles.
        static let sectionLineHeight: CGFloat = 0.95
    }

    /// The eyebrow: 12pt, weight 500, uppercase, tracked 0.20em, `ink-mute` (spec §2.7).
    enum Eyebrow {
        /// Desktop size.
        static let size: CGFloat = 12
        /// The hero's 13pt variant.
        static let heroSize: CGFloat = 13
        /// Couch size.
        static let couchSize: CGFloat = 20
        /// Letter spacing in ems.
        static let trackingEm: CGFloat = 0.20
        /// List headings on Builds use a slightly tighter 0.18em.
        static let listTrackingEm: CGFloat = 0.18
    }

    /// Body line spacing for 17pt copy at line-height 1.65 (extra points between lines).
    static let leadLineSpacing: CGFloat = 11
    /// Body line spacing for 16pt copy at line-height 1.5.
    static let calloutLineSpacing: CGFloat = 8

    /// A display size that tracks the window width, clamped (CSS `clamp(min, share·vw, max)`).
    static func clampedDisplay(width: CGFloat, min lower: CGFloat, share: CGFloat, max upper: CGFloat) -> CGFloat {
        Swift.min(upper, Swift.max(lower, width * share))
    }

    /// Letter spacing in points for `em` at `size`.
    static func tracking(em: CGFloat, size: CGFloat) -> CGFloat {
        em * size
    }
}
