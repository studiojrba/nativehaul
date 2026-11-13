import SwiftUI

// Build log metrics are token source (make-export-nov13 BuildLog.tsx, 1:1), so the magic-number rule is off here.
// swiftlint:disable no_magic_numbers

extension ShellLayout {
    /// The shared build log (notes 15, 18): Make's `BuildLog` values, 1:1.
    enum BuildLog {
        /// One log line (`leading-6`).
        static let lineHeight: CGFloat = 24
        /// Header height (`h-8`).
        static let headerHeight: CGFloat = 32
        /// Body vertical padding (`py-2`).
        static let bodyVertical: CGFloat = 8
        /// Body and header leading padding (`px-4`, `pl-4`).
        static let horizontal: CGFloat = 16
        /// Header trailing padding (`pr-2`).
        static let headerTrailing: CGFloat = 8
        /// Lines visible at the default (and minimum) height.
        static let defaultLines = 3
        /// Lines visible when expanded.
        static let expandedLines = 12
        /// The expanded height never passes this share of the window.
        static let expandedWindowShare: CGFloat = 0.40
        /// Corner radius (`rounded-[20px]`).
        static let radius: CGFloat = 20
        /// Fill: `bezel` at this opacity (`bg-bezel/90`).
        static let fillOpacity: Double = 0.90
        /// Top inner highlight: `lamp` at this opacity.
        static let highlightOpacity: Double = 0.08
        /// Header divider: `lamp` at this opacity (`border-lamp/8`).
        static let dividerOpacity: Double = 0.08
        /// Header text and icons: `lamp` at this opacity.
        static let headerOpacity: Double = 0.45
        /// Header text size (`text-[10px]`).
        static let headerSize: CGFloat = 10
        /// Header tracking in ems (`tracking-[0.16em]`).
        static let headerTrackingEm: CGFloat = 0.16
        /// Header icon (`size={12}`).
        static let headerIcon: CGFloat = 12
        /// Header icon to title (`gap-2`).
        static let headerGap: CGFloat = 8
        /// Step button (`h-6 w-6`).
        static let stepSize: CGFloat = 24
        /// Step icon (`size={13}`).
        static let stepIcon: CGFloat = 13
        /// Gap between the step buttons (`gap-0.5`).
        static let stepGap: CGFloat = 2
        /// Step button hover: `lamp` fill at this opacity.
        static let stepHoverFill: Double = 0.08
        /// Step button hover: icon `lamp` at this opacity.
        static let stepHoverOpacity: Double = 0.80
        /// Disabled step button opacity.
        static let stepDisabledOpacity: Double = 0.35
        /// Line text size (`text-[11px]`).
        static let lineSize: CGFloat = 11
        /// Line text: `lamp` at this opacity.
        static let lineOpacity: Double = 0.70
        /// The chevron: `accent` at this opacity.
        static let chevronOpacity: Double = 0.70
        /// Chevron to text (`mr-2`).
        static let chevronGap: CGFloat = 8
        /// The live caret's width (`w-[6px]`).
        static let caretWidth: CGFloat = 6
        /// The live caret: `lamp` at this opacity.
        static let caretOpacity: Double = 0.50
        /// The live caret's leading gap (`ml-1`).
        static let caretGap: CGFloat = 4
        /// The newest line counts as followed within this distance of the bottom.
        static let followSlack: CGFloat = 24

        /// The default and minimum height: header + padding + three lines.
        static var defaultHeight: CGFloat {
            headerHeight + bodyVertical * 2 + lineHeight * CGFloat(defaultLines)
        }

        /// The expanded height: twelve lines, capped at 40% of `windowHeight`, never below the default.
        static func expandedHeight(windowHeight: CGFloat?) -> CGFloat {
            let tall = headerHeight + bodyVertical * 2 + lineHeight * CGFloat(expandedLines)
            guard let windowHeight else { return tall }
            return max(defaultHeight, min(tall, (windowHeight * expandedWindowShare).rounded(.down)))
        }
    }
}

// swiftlint:enable no_magic_numbers
