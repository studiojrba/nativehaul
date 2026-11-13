import SwiftUI

extension CouchLayout {
    /// The launch phase ("Here we go…").
    enum Launch {
        /// Cover width.
        static let coverWidth: CGFloat = 256
        /// Cover radius.
        static let coverRadius: CGFloat = 32
        /// Title size (display).
        static let title: CGFloat = 64
        /// Subtitle size.
        static let subtitle: CGFloat = 24
        /// Cover → title.
        static let titleTop: CGFloat = 48
        /// Title → subtitle.
        static let subtitleTop: CGFloat = 16
    }

    /// The Resume/Close card (and the force-quit offer and messages).
    enum Paused {
        /// Card width (`min(720px, 80vw)`).
        static let width: CGFloat = 720
        /// See ``width``.
        static let widthShare: CGFloat = 0.8
        /// Card radius.
        static let radius: CGFloat = 48
        /// Card padding.
        static let padding: CGFloat = 48
        /// Header gap.
        static let headerGap: CGFloat = 32
        /// Cover width.
        static let coverWidth: CGFloat = 128
        /// Cover radius.
        static let coverRadius: CGFloat = 22
        /// Eyebrow size.
        static let eyebrow: CGFloat = 20
        /// Title size (display).
        static let title: CGFloat = 60
        /// Title lines before it shrinks.
        static let titleLines = 2
        /// Eyebrow → title.
        static let titleTop: CGFloat = 8
        /// Body copy (force-quit warning, messages).
        static let body: CGFloat = 24
        /// Header → buttons.
        static let buttonsTop: CGFloat = 40
        /// Gap between the buttons.
        static let buttonGap: CGFloat = 20
        /// Button height.
        static let buttonHeight: CGFloat = 96
        /// Button radius.
        static let buttonRadius: CGFloat = 30
        /// Button text.
        static let buttonText: CGFloat = 28
        /// Focused scale.
        static let focusScale: CGFloat = 1.04
        /// Focus ring offset.
        static let ringOffset: CGFloat = 4
        /// Unfocused button fill (`surface` 50%).
        static let unfocusedOpacity: Double = 0.5
        /// Buttons → prompts.
        static let promptsTop: CGFloat = 32
        /// Backdrop (`paper` 30% + blur).
        static let backdropOpacity: Double = 0.3
    }

    /// The nav column (the sidebar's couch equivalent; undesigned, derived from the nav island).
    enum Nav {
        /// Distance from the left edge.
        static let leading: CGFloat = 32
        /// Column width.
        static let width: CGFloat = 320
        /// Padding inside the panel.
        static let padding: CGFloat = 16
        /// Panel radius.
        static let radius: CGFloat = 40
        /// One item's height.
        static let itemHeight: CGFloat = 72
        /// Item corner radius.
        static let itemRadius: CGFloat = 28
        /// Icon size.
        static let icon: CGFloat = 28
        /// Label size.
        static let label: CGFloat = 26
        /// Icon → label.
        static let itemGap: CGFloat = 20
        /// Item padding.
        static let itemPadding: CGFloat = 22
        /// Gap between items.
        static let gap: CGFloat = 8
    }
}
