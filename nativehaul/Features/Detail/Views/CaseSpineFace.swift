import SwiftUI

/// The case's spine (spec §3.3): the frame colour, the mark at the top and the short title running down it.
struct CaseSpineFace: View {
    /// What is printed on the case.
    let artwork: CaseArtwork

    private typealias Metrics = ShellLayout.GameCase
    private static let quarterTurn: Double = 90

    var body: some View {
        VStack(spacing: Metrics.spineTitleTop) {
            CaseMark(color: artwork.colors.label.color, punch: artwork.colors.front.color)
                .frame(width: Metrics.spineMark, height: Metrics.spineMark)
            GeometryReader { proxy in
                Text(artwork.shortTitle)
                    .font(Typeface.sans(Metrics.spineTitleSize, weight: .semibold))
                    .foregroundStyle(artwork.colors.label.color)
                    .lineLimit(1)
                    .frame(width: proxy.size.height, height: proxy.size.width, alignment: .leading)
                    .rotationEffect(.degrees(Self.quarterTurn))
                    .frame(width: proxy.size.width, height: proxy.size.height)
            }
        }
        .padding(.vertical, Metrics.spinePadding)
        .frame(width: Metrics.depth, height: Metrics.height)
        .background(artwork.colors.front.color)
    }
}

#Preview {
    CaseSpineFace(artwork: .preview)
        .padding(DesignTokens.Spacing.xl)
}
