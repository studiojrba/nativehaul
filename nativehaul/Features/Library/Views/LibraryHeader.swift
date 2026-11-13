import SwiftUI

/// The Library header (spec §3.2): "Your shelf." with an accent period, the shelf in a sentence, and the sort pill on
/// the right, bottom-aligned.
struct LibraryHeader: View {
    /// The shelf in numbers.
    let summary: ShelfSummary
    /// The sort order.
    @Binding var sort: LibrarySort
    /// The page width (the title tracks it).
    let pageWidth: CGFloat

    var body: some View {
        HStack(alignment: .bottom, spacing: ShellLayout.Library.headerGap) {
            VStack(alignment: .leading, spacing: 0) {
                Eyebrow("Library")
                DisplayHeadline(
                    lead: "Your shelf",
                    trailing: ".",
                    size: TypeStyle.clampedDisplay(
                        width: pageWidth,
                        min: ShellLayout.Library.titleMin,
                        share: ShellLayout.Library.titleWidthShare,
                        max: ShellLayout.Library.titleMax
                    ),
                    lineHeight: ShellLayout.Library.titleLineHeight,
                    isTrailingAccented: true
                )
                .padding(.top, ShellLayout.Library.titleTop)
                Text(summary.librarySubtitle)
                    .font(Typeface.sans(TypeStyle.Size.lead))
                    .foregroundStyle(Theme.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, ShellLayout.Library.subtitleTop)
            }
            .riseIn()
            Spacer(minLength: 0)
            SegmentedPill(options: LibrarySort.allCases, selection: $sort) { $0.title }
                .fixedSize()
        }
    }
}

#Preview {
    @Previewable @State var sort = LibrarySort.recentlyPlayed
    AppearancePreviewPair {
        LibraryHeader(summary: ShelfSummary(games: []), sort: $sort, pageWidth: DesignTokens.Layout.windowMinWidth)
            .padding(KitMetrics.Spacing.section)
    }
}
