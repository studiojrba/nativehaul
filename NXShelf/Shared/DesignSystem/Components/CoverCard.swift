import SwiftUI

/// A grid cell (ADR 0025, ADR 0037): the cover sitting on a saturated field of its own art's colour, the title, and
/// ONE quiet state line underneath in mono.
///
/// - **Colour field:** the tile behind the cover is a gradient of the art's sampled colour, so a grid reads as a
///   saturated mosaic. With no art, the tile is the neutral surface: no fake colour.
/// - **The one hover gesture:** the card lifts and the art scales slightly inside its tile. Nothing else reacts.
///   Under Reduce Motion, hover does nothing.
/// - **Selection** is a strong ring in the primary text colour (the accent is spent only on Play, nav and links).
///
/// Everything is drawn as backgrounds, overlays and transforms, so the grid never reflows.
struct CoverCard<Accessory: View>: View {
    /// Primary text.
    let title: String
    /// The one secondary line (hours played or status).
    let subtitle: String
    /// Local cover image path.
    let imagePath: String?
    /// Whether the card is the current selection.
    var isSelected = false
    /// Optional small view under the subtitle (kept empty in the library grid).
    @ViewBuilder let accessory: () -> Accessory
    @State private var isHovered = false
    @Environment(\.designIntensity) private var intensity
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let level = EnergyLevel.of(intensity)
        let isLifted = isHovered && !reduceMotion
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            CoverArtView(imagePath: imagePath, title: title)
                .scaleEffect(isLifted ? level.hoverArtScale : 1)
                .padding(level.tileInset)
                .background { field(level) }
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.tile))
                .overlay {
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.tile)
                        .strokeBorder(
                            isSelected ? Theme.primaryText : Theme.hairline,
                            lineWidth: isSelected ? DesignTokens.Stroke.emphasis : DesignTokens.Stroke.hairline
                        )
                }
                .offset(y: isLifted ? -level.hoverLift : 0)
            Text(title)
                .font(DesignTokens.Typography.headline)
                .foregroundStyle(Theme.primaryText)
                .lineLimit(DesignTokens.Lines.single)
                .padding(.top, DesignTokens.Spacing.xs)
            Text(subtitle)
                .font(DesignTokens.Typography.monospacedSmall)
                .foregroundStyle(Theme.secondaryText)
                .lineLimit(DesignTokens.Lines.single)
            accessory()
        }
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeOut(duration: DesignTokens.Motion.quick)) { isHovered = hovering }
        }
    }

    @ViewBuilder
    private func field(_ level: EnergyLevel) -> some View {
        if let tint = ArtworkTint.color(forImageAt: imagePath) {
            LinearGradient(
                colors: [
                    tint.opacity(level.tileFieldOpacity),
                    tint.opacity(level.tileFieldOpacity * DesignTokens.ArtTint.fieldFalloff),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            Theme.surfaceRaised
        }
    }
}

extension CoverCard where Accessory == EmptyView {
    /// A card with no accessory: title and one line.
    init(title: String, subtitle: String, imagePath: String?, isSelected: Bool = false) {
        self.init(title: title, subtitle: subtitle, imagePath: imagePath, isSelected: isSelected) { EmptyView() }
    }
}

#Preview {
    HStack(spacing: DesignTokens.Spacing.xl) {
        CoverCard(title: "Tideborn", subtitle: "66h 42m · SteamSynced", imagePath: nil)
        CoverCard(title: "Ridgeback", subtitle: "Backlog", imagePath: nil, isSelected: true)
    }
    .frame(width: DesignTokens.Cover.minWidth * 2 + DesignTokens.Spacing.xl)
    .padding(DesignTokens.Spacing.xl)
    .background(Theme.canvas)
}
