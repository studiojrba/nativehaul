import SwiftUI

// Screen metrics are token source (spec §3.4), so the magic-number rule is off here.
// swiftlint:disable no_magic_numbers

extension ShellLayout {
    /// The Builds page (spec §3.4): the list a third wide (at least 320pt), the selected build on a wash panel.
    enum Builds {
        /// The list column's minimum width.
        static let listMinWidth: CGFloat = 320
        /// The list column's share of the page (`1fr / 2fr`).
        static let listShare: CGFloat = 1.0 / 3.0
        /// List column padding: leading (clears the nav island).
        static let listLeading: CGFloat = 128
        /// List column padding: trailing.
        static let listTrailing: CGFloat = 32
        /// List column padding: top.
        static let listTop: CGFloat = 128
        /// List column padding: bottom.
        static let listBottom: CGFloat = 80
        /// Eyebrow to title, title to subtitle.
        static let titleGap: CGFloat = 12
        /// Title line height.
        static let titleLineHeight: CGFloat = 0.92
        /// Subtitle to the first list (and between lists).
        static let listGap: CGFloat = 40
        /// List heading to its rows.
        static let listHeadingGap: CGFloat = 12
        /// Gap between rows.
        static let rowGap: CGFloat = 8
        /// Row radius.
        static let rowRadius: CGFloat = 22
        /// Row padding.
        static let rowPadding: CGFloat = 10
        /// Row trailing padding.
        static let rowTrailing: CGFloat = 16
        /// Gap between the thumb and the text.
        static let rowGapInside: CGFloat = 16
        /// Cover thumb size.
        static let thumb = CGSize(width: 48, height: 64)
        /// Row title to status line.
        static let rowStatusTop: CGFloat = 2
        /// Status line to the bar.
        static let rowBarTop: CGFloat = 8
        /// Hovered row: `surface` at this opacity.
        static let rowHoverOpacity: Double = 0.50
        /// Detail column padding: trailing.
        static let detailTrailing: CGFloat = 56
        /// Detail column padding: top.
        static let detailTop: CGFloat = 112
        /// Detail column padding: bottom.
        static let detailBottom: CGFloat = 96
        /// The wash panel's inset (top, bottom and trailing).
        static let panelInset: CGFloat = 24
        /// The wash panel's radius.
        static let panelRadius: CGFloat = 48
        /// Content horizontal padding inside the panel.
        static let contentHorizontal: CGFloat = 56
        /// Content top padding inside the panel.
        static let contentTop: CGFloat = 24
        /// Wash lifts: first.
        static let washLiftFirst: Double = 0.70
        /// Wash lifts: last.
        static let washLiftLast: Double = 0.35
        /// Slideshow stage height: minimum.
        static let stageMin: CGFloat = 260
        /// Slideshow stage height: share of the window height.
        static let stageShare: CGFloat = 0.42
        /// Slideshow stage height: maximum.
        static let stageMax: CGFloat = 440
        /// Shot frame padding.
        static let shotFramePadding: CGFloat = 6
        /// Shot frame radius.
        static let shotFrameRadius: CGFloat = 22
        /// Shot image radius.
        static let shotRadius: CGFloat = 17
        /// Inactive shot scale.
        static let shotRestScale: CGFloat = 0.97
        /// Crossfade (seconds).
        static let crossfade: Double = 1.2
        /// Auto-advance (seconds).
        static let advance: Double = 3.6
        /// Stage to dots.
        static let dotsTop: CGFloat = 20
        /// Gap between dots.
        static let dotGap: CGFloat = 8
        /// Active dot width.
        static let dotActiveWidth: CGFloat = 24
        /// Dot size.
        static let dotSize: CGFloat = 6
        /// Inactive dot: `ink` at this opacity.
        static let dotOpacity: Double = 0.25
        /// Slideshow to header.
        static let headerTop: CGFloat = 40
        /// Gap between the header text and its button.
        static let headerGap: CGFloat = 32
        /// Header title size: minimum.
        static let titleMin: CGFloat = 44
        /// Header title size: share of the window width.
        static let titleWidthShare: CGFloat = 0.046
        /// Header title size: maximum.
        static let titleMax: CGFloat = 72
        /// Header title line height.
        static let headerTitleLineHeight: CGFloat = 0.95
        /// Header button height.
        static let buttonHeight: CGFloat = 48
        /// Header button horizontal padding.
        static let buttonHorizontal: CGFloat = 20
        /// Header button icon.
        static let buttonIcon: CGFloat = 15
        /// Ready chip: `surface` at this opacity.
        static let chipOpacity: Double = 0.80
        /// Header to the segmented bar.
        static let progressTop: CGFloat = 40
        /// Gap between segments.
        static let segmentGap: CGFloat = 6
        /// Segment to its name.
        static let segmentNameTop: CGFloat = 12
        /// Name to the explanation.
        static let explanationTop: CGFloat = 2
        /// Segment track: `surface` at this opacity by day.
        static let trackDayOpacity: Double = 0.70
        /// Segment track: `paper-2` at this opacity by night.
        static let trackNightOpacity: Double = 0.80
        /// Inset shadow on the track, by day.
        static let trackDayShadow = ShadowLayer(
            y: 1,
            blur: 2,
            color: RGBA(red8: 110, green8: 70, blue8: 20, alpha: 0.12)
        )
        /// Inset shadow on the track, by night.
        static let trackNightShadow = ShadowLayer(
            y: 1,
            blur: 2,
            color: RGBA(red8: 10, green8: 6, blue8: 3, alpha: 0.50)
        )
        /// Bar to the stat cards.
        /// Stage bar to the build log (Make `mt-7`).
        static let logTop: CGFloat = 28
        static let statsTop: CGFloat = 32
        /// Gap between stat cards.
        static let statsGap: CGFloat = 16
        /// Stat card radius.
        static let statRadius: CGFloat = 24
        /// Stat card horizontal padding.
        static let statHorizontal: CGFloat = 20
        /// Stat card vertical padding.
        static let statVertical: CGFloat = 16
        /// Stat label to value.
        static let statValueTop: CGFloat = 4
        /// Stat cards to the job's tools.
        static let toolsTop: CGFloat = 48
        /// Gap between the job's tools.
        static let toolsGap: CGFloat = 20
    }
}

// swiftlint:enable no_magic_numbers
