import SwiftUI

/// The editorial note (spec §3.3): a `cream` 60% card with the quote in display type and the signature underneath.
struct EditorialNoteCard: View {
    /// The quote (without quotation marks).
    let quote: String

    var body: some View {
        VStack(alignment: .leading, spacing: ShellLayout.Detail.noteCaptionTop) {
            Text("“\(quote)”")
                .font(Typeface.display(TypeStyle.DisplaySize.quote))
                .lineSpacing(ShellLayout.Detail.quoteLineSpacing)
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text("— nativehaul, keeping count so you don’t have to")
                .font(Typeface.sans(TypeStyle.Size.small))
                .foregroundStyle(Theme.inkMute)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, ShellLayout.Detail.noteHorizontal)
        .padding(.vertical, ShellLayout.Detail.noteVertical)
        .background(
            RoundedRectangle(cornerRadius: KitMetrics.Radius.note, style: .continuous)
                .fill(Theme.cream.opacity(ShellLayout.Detail.noteFillOpacity))
        )
    }
}

#Preview {
    AppearancePreviewPair {
        EditorialNoteCard(quote: "You’ve spent 11h 40m here. That’s 6 long evenings — not bad at all.")
            .frame(width: ShellLayout.Detail.descriptionMaxWidth)
            .padding(DesignTokens.Spacing.xl)
    }
}
