import SwiftUI

/// One couch Settings row: its label and value (a volume bar for Music volume). Focused, it lifts onto `surface` with
/// the accent ring.
struct CouchSettingsRowView: View {
    /// The row.
    let row: CouchSettingsRow
    /// Its value ("On", "Dark", "60%").
    let value: String
    /// Music volume, 0…1 (for the bar).
    let volume: Double
    /// Whether it has focus.
    let isFocused: Bool
    /// The couch scale.
    let scale: CouchScale

    private typealias Metrics = CouchLayout.Settings

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: scale(Metrics.rowRadius), style: .continuous)
        HStack(spacing: scale(Metrics.rowPadding)) {
            Text(row.title)
                .font(Typeface.sans(scale(Metrics.label), weight: row == .exitToDesktop ? .medium : .regular))
                .foregroundStyle(Theme.ink)
            Spacer(minLength: 0)
            if row == .musicVolume {
                PillProgressBar(value: volume, height: scale(Metrics.volumeHeight))
                    .frame(width: scale(Metrics.volumeWidth))
            }
            Text(value)
                .font(Typeface.sans(scale(Metrics.value)))
                .foregroundStyle(Theme.inkSoft)
                .monospacedDigit()
        }
        .padding(.horizontal, scale(Metrics.rowPadding))
        .frame(height: scale(Metrics.rowHeight))
        .background { shape.fill(isFocused ? Theme.surface : .clear) }
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
            CouchSettingsRowView(row: .music, value: "On", volume: 0.6, isFocused: false, scale: scale)
            CouchSettingsRowView(row: .musicVolume, value: "60%", volume: 0.6, isFocused: true, scale: scale)
            CouchSettingsRowView(row: .exitToDesktop, value: "", volume: 0.6, isFocused: false, scale: scale)
        }
        .padding(KitMetrics.Spacing.page)
    }
}
