import SwiftUI

/// A display headline in Instrument Serif (spec §2.7, §3): "{lead} *{emphasis}*." with the emphasised phrase in
/// italic `ink-soft`.
struct DisplayHeadline: View {
    /// The plain lead.
    let lead: String
    /// The emphasised phrase (italic, `ink-soft`), if any.
    var emphasis: String?
    /// Trailing punctuation after the emphasis.
    var trailing: String = ""
    /// Point size.
    var size: CGFloat = TypeStyle.DisplaySize.section
    /// Line height as a multiple of the size (CSS `line-height`).
    var lineHeight: CGFloat = TypeStyle.DisplaySize.sectionLineHeight
    /// Paints the trailing punctuation in the accent ("Your shelf." on Library, spec §3.2).
    var isTrailingAccented = false
    /// Letter spacing in ems.
    var trackingEm: CGFloat = 0

    var body: some View {
        headline
            .font(Typeface.display(size))
            .foregroundStyle(Theme.ink)
            .tracking(TypeStyle.tracking(em: trackingEm, size: size))
            .lineSpacing(size * lineHeight - size)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var headline: Text {
        let end = isTrailingAccented ? Text(trailing).foregroundStyle(Theme.accent) : Text(trailing)
        guard let emphasis else { return Text(lead) + end }
        let separator = lead.isEmpty ? "" : " "
        return Text(lead + separator)
            + Text(emphasis).font(Typeface.displayItalic(size)).foregroundStyle(Theme.inkSoft)
            + end
    }
}

#Preview {
    AppearancePreviewPair {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            DisplayHeadline(lead: "Still on", emphasis: "the go", trailing: ".")
            DisplayHeadline(lead: "The whole shelf", size: TypeStyle.DisplaySize.card)
            DisplayHeadline(lead: "Your shelf", trailing: ".", isTrailingAccented: true)
        }
        .padding(DesignTokens.Spacing.xl)
    }
}
