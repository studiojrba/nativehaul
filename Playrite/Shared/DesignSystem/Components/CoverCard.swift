import SwiftUI

/// A grid cell (ADR 0025, Steam-style restraint): cover art, the title, and ONE quiet state-driven line underneath.
///
/// Hover brightens a hairline ring and lays a faint wash of the art's own colour behind the card; selection uses the
/// accent ring. Both are overlays/backgrounds, so the grid never reflows.
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

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            CoverArtView(imagePath: imagePath, title: title)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                        .strokeBorder(ringColor, lineWidth: ringWidth)
                )
            Text(title)
                .font(DesignTokens.Typography.headline)
                .foregroundStyle(Theme.primaryText)
                .lineLimit(DesignTokens.Lines.single)
                .padding(.top, DesignTokens.Spacing.xs)
            Text(subtitle)
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(Theme.secondaryText)
                .lineLimit(DesignTokens.Lines.single)
            accessory()
        }
        .background {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                .fill(hoverWash)
                .padding(-DesignTokens.Spacing.sm)
        }
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeOut(duration: DesignTokens.Motion.quick)) { isHovered = hovering }
        }
    }

    private var ringColor: Color {
        if isSelected {
            return Theme.accent
        }
        return isHovered ? Theme.hairlineStrong : Theme.hairline
    }

    private var ringWidth: CGFloat {
        isSelected ? DesignTokens.Stroke.emphasis : DesignTokens.Stroke.hairline
    }

    private var hoverWash: Color {
        guard isHovered else { return .clear }
        return (ArtworkTint.color(forImageAt: imagePath) ?? Theme.surfaceRaised)
            .opacity(DesignTokens.ArtTint.hoverOpacity)
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
