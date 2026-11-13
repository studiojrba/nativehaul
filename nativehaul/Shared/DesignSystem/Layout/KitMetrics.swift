import SwiftUI

// Component metrics are token source (spec §3, §4.2, §4.3), so the magic-number rule is off here.
// swiftlint:disable no_magic_numbers

/// Metrics for the shared 0.1.0 components (``EmberButtonStyle``, ``ToggleSwitchStyle``, ``SegmentedPill``, …) and
/// the radius/spacing steps the screens use.
enum KitMetrics {
    /// Corner radii used across 0.1.0 screens.
    enum Radius {
        /// Thumbnails.
        static let thumb: CGFloat = 12
        /// Info bars, header bars, group icons.
        static let bar: CGFloat = 16
        /// Covers on small shelves, bubbles, rows.
        static let card: CGFloat = 22
        /// Shelf covers, stat cards, dropdowns.
        static let cover: CGFloat = 24
        /// Library covers.
        static let libraryCover: CGFloat = 26
        /// Screenshots.
        static let shot: CGFloat = 28
        /// Settings groups, replay card.
        static let panel: CGFloat = 32
        /// Editorial note, onboarding shelf.
        static let note: CGFloat = 36
        /// Launch card, drop zones.
        static let sheet: CGFloat = 40
        /// Curated shelf panels.
        static let stage: CGFloat = 48
    }

    /// Spacing steps beyond ``DesignTokens/Spacing``.
    enum Spacing {
        /// 20.
        static let gutter: CGFloat = 20
        /// 28.
        static let roomy: CGFloat = 28
        /// 40.
        static let section: CGFloat = 40
        /// 56.
        static let block: CGFloat = 56
        /// 64.
        static let page: CGFloat = 64
        /// 96.
        static let chapter: CGFloat = 96
    }

    /// The accent pill and the surface pill (Keep playing / About the game).
    enum PillButton {
        /// Height.
        static let height: CGFloat = 56
        /// Leading padding (icon side).
        static let leadingPadding: CGFloat = 24
        /// Trailing padding.
        static let trailingPadding: CGFloat = 28
        /// Icon size.
        static let iconSize: CGFloat = 17
        /// Gap between icon and label.
        static let gap: CGFloat = 10
        /// Surface pill fill opacity.
        static let surfaceOpacity: Double = 0.70
        /// Compact pill (onboarding actions) vertical padding.
        static let compactVertical: CGFloat = 12
        /// Compact pill horizontal padding.
        static let compactHorizontal: CGFloat = 20
    }

    /// Press feedback (spec §4.3).
    enum Press {
        /// Hover lift.
        static let hoverLift: CGFloat = -2
        /// Pressed drop.
        static let pressedDrop: CGFloat = 1
        /// Pressed scale.
        static let pressedScale: CGFloat = 0.98
    }

    /// The shared toggle switch (spec §3.5).
    enum Switch {
        /// Track size.
        static let track = CGSize(width: 56, height: 32)
        /// Knob diameter.
        static let knob: CGFloat = 24
        /// Knob inset from the track edge.
        static let inset: CGFloat = 4
        /// Off track: `ink` at this opacity.
        static let offOpacity: Double = 0.12
        /// Hovered off track.
        static let hoverOffOpacity: Double = 0.15
        /// Knob nudge on hover.
        static let hoverNudge: CGFloat = 4
    }

    /// The segmented pill (spec §3.2 sort control, §3.5 appearance picker).
    enum Segmented {
        /// Padding around the segments.
        static let padding: CGFloat = 4
        /// Segment horizontal padding.
        static let horizontal: CGFloat = 16
        /// Segment vertical padding.
        static let vertical: CGFloat = 8
        /// Icon size inside a segment.
        static let iconSize: CGFloat = 14
    }

    /// Bare chevrons (spec §4.2).
    enum Chevron {
        /// Glyph size.
        static let size: CGFloat = 26
        /// Hero glyph size.
        static let heroSize: CGFloat = 34
        /// Stroke.
        static let stroke: CGFloat = 1.6
        /// Padding (the hit area).
        static let padding: CGFloat = 8
        /// Resting opacity (light `ink` / dark `lamp`).
        static let lightOpacity: Double = 0.35
        /// Hovered opacity, light.
        static let lightHoverOpacity: Double = 0.70
        /// Resting opacity, dark.
        static let darkOpacity: Double = 0.40
        /// Hovered opacity, dark.
        static let darkHoverOpacity: Double = 0.80
        /// Couch-focused scale.
        static let focusScale: CGFloat = 1.35
        /// Legibility shadow by day.
        static let dayShadow = ShadowLayer(y: 1, blur: 2, color: RGBA(red8: 36, green8: 35, blue8: 40, alpha: 0.18))
        /// Legibility shadow by night.
        static let nightShadow = ShadowLayer(y: 1, blur: 3, color: RGBA(red8: 10, green8: 6, blue8: 3, alpha: 0.60))
    }

    /// Progress bars.
    enum Progress {
        /// Thin row bar.
        static let thin: CGFloat = 4
        /// Launch bar.
        static let regular: CGFloat = 6
        /// Builds stage bar.
        static let thick: CGFloat = 12
        /// Track: `ink` at this opacity.
        static let trackOpacity: Double = 0.10
        /// Quiet (non-accent) fill: `ink` at this opacity.
        static let quietFillOpacity: Double = 0.70
    }

    /// Frosted glass (spec §2.3).
    enum Frost {
        /// Edge stroke width (dark only).
        static let edgeWidth: CGFloat = 1
        /// A 1pt stroke straddles its path; inset by half its width it stays inside (the ember's top light).
        static let innerLightInset: CGFloat = 0.5
        /// Pill padding.
        static let pillHorizontal: CGFloat = 16
        /// Pill vertical padding.
        static let pillVertical: CGFloat = 8
    }
}

// swiftlint:enable no_magic_numbers
