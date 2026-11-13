import SwiftUI

/// The case's front (spec §3.3): the frame with its band — the mark and the label — over the real cover art, inset by
/// 2.5%.
struct CaseFrontFace: View {
    /// What is printed on the case.
    let artwork: CaseArtwork

    private typealias Metrics = ShellLayout.GameCase

    var body: some View {
        VStack(spacing: 0) {
            CaseBand(artwork: artwork, showsMark: true, sidePadding: Metrics.width * Metrics.headerSideShare)
            ArtworkFill(path: artwork.coverPath, title: artwork.title)
                .clipShape(RoundedRectangle(cornerRadius: Metrics.innerRadius, style: .continuous))
                .padding(.horizontal, Metrics.width * Metrics.insetShare)
                .padding(.bottom, Metrics.width * Metrics.insetShare)
        }
        .frame(width: Metrics.width, height: Metrics.height)
        .background(artwork.colors.front.color)
        .clipShape(RoundedRectangle(cornerRadius: Metrics.outerRadius, style: .continuous))
    }
}

#Preview {
    CaseFrontFace(artwork: .preview)
        .padding(DesignTokens.Spacing.xl)
}
