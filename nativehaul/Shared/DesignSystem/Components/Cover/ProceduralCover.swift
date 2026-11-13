import SwiftUI

/// A drawn cover (make-export-nov13 `Cover`): an editorial poster from the game's palette and motif, filling its frame
/// edge to edge (the 300×420 art is scaled to cover, centred), with the studio and title set at the foot. It is the
/// default cover wherever no cover image exists; any user-supplied art source still wins (``ArtworkFill``). The caller
/// sizes and clips it.
struct ProceduralCover: View {
    /// The game's title (picks the palette and motif, and is shown).
    let title: String
    /// The studio, when known (shown small above the title).
    var studio: String?
    /// The em size the title block is set from (Make's `text-[Npx]` on the cover): title 1.45em, studio 0.55em.
    var baseSize: CGFloat = TypeStyle.Size.body
    /// Whether the studio and title are shown.
    var showsTitle = true

    private typealias Metrics = ShellLayout.DrawnCover
    /// Centring splits the overflow in two.
    private static let halves: CGFloat = 2

    var body: some View {
        let palette = CoverPalette.forTitle(title)
        Canvas { context, size in
            draw(in: &context, size: size, palette: palette)
        }
        .background(palette.deep.color)
        .overlay {
            if showsTitle {
                GeometryReader { proxy in
                    titleBlock(ink: palette.ink)
                        .padding(proxy.size.width * Metrics.insetShare)
                        .frame(width: proxy.size.width, height: proxy.size.height, alignment: .bottomLeading)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(title))
    }

    private func draw(in context: inout GraphicsContext, size: CGSize, palette: CoverPalette) {
        let box = Metrics.box
        let scale = max(size.width / box.width, size.height / box.height)
        context.translateBy(
            x: (size.width - box.width * scale) / Self.halves,
            y: (size.height - box.height * scale) / Self.halves
        )
        context.scaleBy(x: scale, y: scale)
        let rect = Path(CGRect(origin: .zero, size: box))
        context.fill(rect, with: .linearGradient(
            Gradient(colors: [palette.deep.color, palette.deep.mixed(with: palette.mid, by: Metrics.groundMix).color]),
            startPoint: .zero,
            endPoint: CGPoint(x: 0, y: box.height)
        ))
        var motifContext = context
        CoverMotifPainter(palette: palette).paint(CoverMotif.forTitle(title), in: &motifContext)
        context.fill(rect, with: .radialGradient(
            Gradient(colors: [Metrics.sheen.color, Metrics.sheen.opacity(0).color]),
            center: CGPoint(x: box.width * Metrics.sheenCenter.x, y: box.height * Metrics.sheenCenter.y),
            startRadius: 0,
            endRadius: box.height * Metrics.sheenRadius
        ))
    }

    private func titleBlock(ink: RGBA) -> some View {
        VStack(alignment: .leading, spacing: baseSize * Metrics.titleGapEm) {
            if let studio, !studio.isEmpty {
                Text(studio.uppercased())
                    .font(Typeface.sans(baseSize * Metrics.studioEm, weight: .medium))
                    .tracking(TypeStyle.tracking(em: Metrics.studioTrackingEm, size: baseSize * Metrics.studioEm))
                    .opacity(Metrics.studioOpacity)
                    .lineLimit(DesignTokens.Lines.single)
            }
            Text(title)
                .font(Typeface.display(baseSize * Metrics.titleEm))
                .lineLimit(DesignTokens.Lines.wrappedTitle)
                .minimumScaleFactor(DesignTokens.Typography.minimumScale)
        }
        .foregroundStyle(ink.color)
    }
}

#Preview {
    AppearancePreviewPair {
        HStack {
            ForEach(["Lantern Coast", "Tideborn", "Moss & Ember", "Velvet Orbit"], id: \.self) { title in
                ProceduralCover(title: title, studio: "Night Kite", baseSize: TypeStyle.Size.body)
                    .frame(width: DesignTokens.Cover.minWidth, height: DesignTokens.Cover.minWidth * 1.4)
                    .clipShape(RoundedRectangle(cornerRadius: KitMetrics.Radius.cover, style: .continuous))
            }
        }
        .padding(DesignTokens.Spacing.xl)
    }
}
