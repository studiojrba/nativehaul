import SwiftUI

extension CouchLayout {
    /// Shared page header on the mirrored screens.
    enum Page {
        /// Top of the page title (clears the couch header).
        static let top: CGFloat = 120
        /// Eyebrow size.
        static let eyebrow: CGFloat = 20
        /// Page title (display).
        static let title: CGFloat = 72
        /// Subtitle size.
        static let subtitle: CGFloat = 24
        /// Title → subtitle.
        static let subtitleTop: CGFloat = 12
        /// Header → content.
        static let contentTop: CGFloat = 40
        /// Room at the bottom for the prompt bar.
        static let bottomClearance: CGFloat = 160
    }

    /// Couch Library's grid.
    enum Library {
        /// Gap between grid rows.
        static let rowGap: CGFloat = 48
    }

    /// Couch Detail.
    enum Detail {
        /// Case width (share of the screen height).
        static let caseWidthShare: CGFloat = 0.30
        /// Gap between the case and the text column.
        static let columnGap: CGFloat = 96
        /// Text column max width.
        static let textMaxWidth: CGFloat = 900
        /// Title size (display).
        static let title: CGFloat = 80
        /// Summary size.
        static let summary: CGFloat = 24
        /// Summary lines.
        static let summaryLines = 4
        /// Spec label size.
        static let specLabel: CGFloat = 18
        /// Spec value size.
        static let specValue: CGFloat = 24
        /// Spec rows shown.
        static let specLimit = 5
        /// Spec row padding.
        static let specRowPadding: CGFloat = 12
        /// Block gap.
        static let blockGap: CGFloat = 28
        /// Button height.
        static let buttonHeight: CGFloat = 80
        /// Button text.
        static let buttonText: CGFloat = 26
        /// Button padding.
        static let buttonPadding: CGFloat = 40
        /// Gap between buttons.
        static let buttonGap: CGFloat = 24
        /// Focused button scale.
        static let focusScale: CGFloat = 1.06
        /// Room under the content (above the prompt bar).
        static let bottomInset: CGFloat = 80
        /// Specs → buttons.
        static let buttonsTop: CGFloat = 14
    }

    /// Couch Builds.
    enum Builds {
        /// List width.
        static let listWidth: CGFloat = 560
        /// List row height.
        static let rowHeight: CGFloat = 104
        /// Row radius.
        static let rowRadius: CGFloat = 32
        /// Row cover width.
        static let rowCover: CGFloat = 60
        /// Row title.
        static let rowTitle: CGFloat = 26
        /// Row sub line.
        static let rowSub: CGFloat = 20
        /// Row padding.
        static let rowPadding: CGFloat = 20
        /// Gap between rows.
        static let rowGap: CGFloat = 12
        /// Gap between the list and the panel.
        static let columnGap: CGFloat = 56
        /// Panel radius.
        static let panelRadius: CGFloat = 48
        /// Panel padding.
        static let panelPadding: CGFloat = 48
        /// Panel cover width.
        static let panelCover: CGFloat = 200
        /// Panel title (display).
        static let panelTitle: CGFloat = 56
        /// Panel body.
        static let panelBody: CGFloat = 24
        /// Segment height.
        static let segmentHeight: CGFloat = 16
        /// Gap between segments.
        static let segmentGap: CGFloat = 10
        /// Stage name size.
        static let stageName: CGFloat = 18
        /// Block gap.
        static let blockGap: CGFloat = 28
    }

    /// Couch Settings.
    enum Settings {
        /// Card max width.
        static let width: CGFloat = 1100
        /// Card radius.
        static let radius: CGFloat = 48
        /// Card padding.
        static let padding: CGFloat = 24
        /// Row height.
        static let rowHeight: CGFloat = 88
        /// Row radius.
        static let rowRadius: CGFloat = 32
        /// Row padding.
        static let rowPadding: CGFloat = 28
        /// Row label.
        static let label: CGFloat = 26
        /// Row value.
        static let value: CGFloat = 24
        /// Volume bar width.
        static let volumeWidth: CGFloat = 240
        /// Volume bar height.
        static let volumeHeight: CGFloat = 10
        /// Volume step per press.
        static let volumeStep: Double = 0.1
        /// The note under the card.
        static let note: CGFloat = 20
        /// Card → note.
        static let noteTop: CGFloat = 24
    }
}
