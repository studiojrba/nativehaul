import SwiftUI

/// One build in couch Builds' list: the cover, the short title and its stage line. Focused, it lifts onto `surface`
/// with the accent ring.
struct CouchBuildRow: View {
    /// The short title.
    let title: String
    /// "Verify · 40%" and the like.
    let detail: String
    /// Cover art.
    let coverPath: String?
    /// Whether it has focus.
    let isFocused: Bool
    /// The couch scale.
    let scale: CouchScale

    private typealias Metrics = CouchLayout.Builds

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: scale(Metrics.rowRadius), style: .continuous)
        HStack(spacing: scale(Metrics.rowPadding)) {
            ArtworkFill(path: coverPath, title: title, placeholderSize: scale(Metrics.rowSub))
                .frame(width: scale(Metrics.rowCover), height: scale(Metrics.rowCover) / CouchLayout.Tile.aspect)
                .clipShape(RoundedRectangle(cornerRadius: scale(CouchLayout.Tile.ringOffset), style: .continuous))
            VStack(alignment: .leading, spacing: scale(CouchLayout.PromptBar.glyphGap)) {
                Text(title)
                    .font(Typeface.sans(scale(Metrics.rowTitle), weight: .medium))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(1)
                Text(detail)
                    .font(Typeface.sans(scale(Metrics.rowSub)))
                    .foregroundStyle(Theme.inkSoft)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, scale(Metrics.rowPadding))
        .frame(height: scale(Metrics.rowHeight))
        .background {
            shape.fill(isFocused ? Theme.surface : Theme.surface.opacity(CouchLayout.Paused.unfocusedOpacity))
        }
        .couchFocusRing(
            isFocused,
            in: shape,
            width: scale(CouchLayout.Tile.ringWidth),
            offset: scale(CouchLayout.Paused.ringOffset)
        )
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    let scale = CouchScale(size: CGSize(width: DesignTokens.Layout.windowMinWidth, height: CouchLayout.referenceHeight))
    AppearancePreviewPair {
        VStack {
            CouchBuildRow(title: "Tideborn", detail: "Verify · 40%", coverPath: nil, isFocused: true, scale: scale)
            CouchBuildRow(title: "Lantern Coast", detail: "Ready", coverPath: nil, isFocused: false, scale: scale)
        }
        .frame(width: scale(CouchLayout.Builds.listWidth))
        .padding(KitMetrics.Spacing.page)
    }
}
