import SwiftUI

/// The band across the top of the case's front and back (spec §3.3): 9% of the height, the mark (front only) and the
/// label in tracked white capitals.
struct CaseBand: View {
    /// What is printed on the case.
    let artwork: CaseArtwork
    /// Whether the mark shows (front).
    let showsMark: Bool
    /// Side padding.
    let sidePadding: CGFloat

    private typealias Metrics = ShellLayout.GameCase

    var body: some View {
        let height = Metrics.height * Metrics.headerShare
        HStack(spacing: Metrics.width * Metrics.headerGapShare) {
            if showsMark {
                CaseMark(color: artwork.colors.label.color, punch: artwork.colors.front.color)
                    .frame(height: height * Metrics.markShare)
            }
            Text(artwork.label.uppercased())
                .font(Typeface.sans(Metrics.frontLabelSize, weight: .semibold))
                .tracking(TypeStyle.tracking(em: Metrics.labelTrackingEm, size: Metrics.frontLabelSize))
                .foregroundStyle(artwork.colors.label.color)
                .lineLimit(1)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, sidePadding)
        .frame(height: height)
    }
}

#Preview {
    CaseBand(artwork: .preview, showsMark: true, sidePadding: DesignTokens.Spacing.md)
        .background(CaseColors.red.front.color)
        .frame(width: ShellLayout.GameCase.width)
        .padding(DesignTokens.Spacing.xl)
}
