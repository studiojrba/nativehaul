import SwiftUI

/// The case's back (spec §3.3): the frame and band, and a light panel printed with the short title, up to four real
/// screenshots, the description and a footer with the studio, the year and a barcode. Print colours are the
/// daylight inks in both appearances: it is a physical object.
struct CaseBackFace: View {
    /// What is printed on the case.
    let artwork: CaseArtwork

    private typealias Metrics = ShellLayout.GameCase

    var body: some View {
        VStack(spacing: 0) {
            CaseBand(artwork: artwork, showsMark: false, sidePadding: Metrics.width * Metrics.backHeaderSideShare)
            panel
                .padding(.horizontal, Metrics.width * Metrics.insetShare)
                .padding(.bottom, Metrics.width * Metrics.insetShare)
        }
        .frame(width: Metrics.width, height: Metrics.height)
        .background(artwork.colors.front.color)
        .clipShape(RoundedRectangle(cornerRadius: Metrics.outerRadius, style: .continuous))
    }

    private var panel: some View {
        VStack(alignment: .leading, spacing: Metrics.backGap) {
            Text(artwork.shortTitle)
                .font(Typeface.display(Metrics.backHeadingSize))
                .foregroundStyle(CaseColors.Print.ink.color)
                .lineLimit(DesignTokens.Lines.title)
            if !artwork.screenshots.isEmpty {
                shots
            }
            if let summary = artwork.summary {
                Text(summary)
                    .font(Typeface.sans(Metrics.backDescriptionSize))
                    .lineSpacing(Metrics.backDescriptionLineSpacing)
                    .foregroundStyle(CaseColors.Print.soft.color)
                    .lineLimit(Metrics.backDescriptionLines)
            }
            Spacer(minLength: 0)
            footer
        }
        .padding(Metrics.backPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(artwork.panel.color)
        .clipShape(RoundedRectangle(cornerRadius: Metrics.innerRadius, style: .continuous))
    }

    private var shots: some View {
        LazyVGrid(
            columns: Array(
                repeating: GridItem(.flexible(), spacing: Metrics.backShotGap),
                count: Metrics.backShotColumns
            ),
            spacing: Metrics.backShotGap
        ) {
            ForEach(artwork.screenshots, id: \.self) { path in
                Color.clear
                    .aspectRatio(Metrics.backShotAspect, contentMode: .fit)
                    .overlay { ArtworkFill(path: path, title: artwork.title, placeholderSize: Metrics.footerSize) }
                    .clipShape(RoundedRectangle(cornerRadius: Metrics.backShotRadius, style: .continuous))
            }
        }
    }

    private var footer: some View {
        HStack(alignment: .bottom, spacing: Metrics.backGap) {
            if let footer = artwork.footer {
                Text(footer.uppercased())
                    .font(Typeface.sans(Metrics.footerSize))
                    .tracking(TypeStyle.tracking(em: Metrics.footerTrackingEm, size: Metrics.footerSize))
                    .foregroundStyle(CaseColors.Print.mute.color)
                    .lineLimit(DesignTokens.Lines.title)
            }
            Spacer(minLength: 0)
            HStack(spacing: Metrics.barcodeGap) {
                ForEach(Array(artwork.barcode.enumerated()), id: \.offset) { bar in
                    Rectangle()
                        .fill(CaseColors.Print.ink.color)
                        .frame(width: CGFloat(bar.element))
                }
            }
            .frame(height: Metrics.barcodeHeight)
            .accessibilityHidden(true)
        }
    }
}

#Preview {
    CaseBackFace(artwork: .preview)
        .padding(DesignTokens.Spacing.xl)
}
