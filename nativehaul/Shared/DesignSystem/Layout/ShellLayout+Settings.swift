import SwiftUI

extension ShellLayout {
    /// The Settings page (spec §3.5): one in-window page of grouped rows.
    enum Settings {
        /// Height of the background wash.
        static let washHeight: CGFloat = 560
        /// Content column maximum width.
        static let maxWidth: CGFloat = 920
        /// Left padding (clears the nav island).
        static let leadingPadding: CGFloat = 96
        /// Right padding.
        static let trailingPadding: CGFloat = 40
        /// Top padding.
        static let topPadding: CGFloat = 144
        /// Bottom padding.
        static let bottomPadding: CGFloat = 128
        /// Eyebrow to title.
        static let titleTop: CGFloat = 16
        /// Title size: minimum (`clamp(60px, 7vw, 104px)`).
        static let titleMin: CGFloat = 60
        /// Title size: share of the window width.
        static let titleWidthShare: CGFloat = 0.07
        /// Title size: maximum.
        static let titleMax: CGFloat = 104
        /// Title line height.
        static let titleLineHeight: CGFloat = 0.9
        /// Title to intro.
        static let introTop: CGFloat = 20
        /// Intro maximum width.
        static let introMaxWidth: CGFloat = 512
        /// Space above each group.
        static let groupTop: CGFloat = 64
        /// Group header to card.
        static let cardTop: CGFloat = 24
        /// Group icon chip size.
        static let chipSize: CGFloat = 40
        /// Group icon chip radius.
        static let chipRadius: CGFloat = 16
        /// Group icon glyph size.
        static let chipIcon: CGFloat = 18
        /// Gap between the chip and the title block.
        static let headerGap: CGFloat = 12
        /// Title to note.
        static let noteTop: CGFloat = 4
        /// Card radius.
        static let cardRadius: CGFloat = 30
        /// Card horizontal padding.
        static let cardHorizontal: CGFloat = 28
        /// Card `surface` opacity.
        static let cardOpacity: Double = 0.65
        /// Row vertical padding.
        static let rowVertical: CGFloat = 20
        /// Gap between a row's label block and its control.
        static let rowGap: CGFloat = 24
        /// Label to sub-line.
        static let subTop: CGFloat = 2
        /// Gap between a label and its badge.
        static let badgeGap: CGFloat = 8
        /// Gap between controls in a row.
        static let controlGap: CGFloat = 12
        /// "Change…" pill horizontal padding.
        static let changeHorizontal: CGFloat = 16
        /// "Change…" pill vertical padding.
        static let changeVertical: CGFloat = 8
        /// "Change…" pill `cream` opacity.
        static let changeOpacity: Double = 0.80
        /// Badge horizontal padding.
        static let badgeHorizontal: CGFloat = 8
        /// Badge vertical padding.
        static let badgeVertical: CGFloat = 2
        /// Badge check glyph.
        static let badgeIcon: CGFloat = 11
        /// Badge gap.
        static let badgeInnerGap: CGFloat = 4
        /// "Default" / "Make default" pill horizontal padding.
        static let defaultHorizontal: CGFloat = 14
        /// "Default" / "Make default" pill vertical padding.
        static let defaultVertical: CGFloat = 6
        /// API key field width.
        static let keyFieldWidth: CGFloat = 300
        /// API key field padding.
        static let keyFieldPadding: CGFloat = 4
        /// API key field leading padding.
        static let keyFieldLeading: CGFloat = 16
        /// Eye button size.
        static let eyeSize: CGFloat = 32
        /// Eye glyph size.
        static let eyeIcon: CGFloat = 15
        /// Save button height.
        static let saveHeight: CGFloat = 32
        /// Save button horizontal padding.
        static let saveHorizontal: CGFloat = 14
        /// Save button opacity when disabled.
        static let saveDisabledOpacity: Double = 0.25
        /// Focus ring: accent at this opacity.
        static let focusOpacity: Double = 0.60
        /// Focus ring width.
        static let focusWidth: CGFloat = 2
        /// Volume slider width.
        static let sliderWidth: CGFloat = 220
        /// Replay card top margin.
        static let replayTop: CGFloat = 56
        /// Replay card horizontal padding.
        static let replayHorizontal: CGFloat = 36
        /// Replay card vertical padding.
        static let replayVertical: CGFloat = 28
        /// Replay card `cream` opacity.
        static let replayOpacity: Double = 0.70
        /// Replay icon chip size.
        static let replayChip: CGFloat = 44
        /// Replay sparkle glyph.
        static let replayIcon: CGFloat = 18
        /// Replay chip to text.
        static let replayGap: CGFloat = 16
        /// Footer top margin.
        static let footerTop: CGFloat = 40
        /// "Behind the scenes" sheet minimum width.
        static let sheetMinWidth: CGFloat = 560
        /// "Behind the scenes" sheet minimum height.
        static let sheetMinHeight: CGFloat = 480
    }
}
