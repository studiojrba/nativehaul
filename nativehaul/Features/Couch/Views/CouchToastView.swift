import SwiftUI

/// A centred frost toast (spec §3.7): a jump letter in the display face at 120pt, or a short message at 32pt, on a
/// 40pt-radius card with `elev-lg`.
struct CouchToastView: View {
    /// The toast.
    let toast: CouchToast
    /// The couch scale.
    let scale: CouchScale

    private typealias Metrics = CouchLayout.Toast

    var body: some View {
        Text(toast.text)
            .font(toast.isLetter ? Typeface.display(scale(Metrics.letter)) : Typeface.sans(scale(Metrics.message)))
            .foregroundStyle(Theme.ink)
            .padding(.horizontal, scale(Metrics.horizontal))
            .padding(.vertical, scale(Metrics.vertical))
            .frame(minWidth: scale(Metrics.minWidth))
            .frostedGlass(in: RoundedRectangle(cornerRadius: scale(Metrics.radius), style: .continuous))
            .elevation(.large)
            .riseIn()
            .accessibilityAddTraits(.updatesFrequently)
    }
}

#Preview {
    let scale = CouchScale(size: CGSize(width: DesignTokens.Layout.windowMinWidth, height: CouchLayout.referenceHeight))
    AppearancePreviewPair {
        HStack(spacing: DesignTokens.Spacing.xl) {
            CouchToastView(toast: .letter("M"), scale: scale)
            CouchToastView(toast: .youreHome, scale: scale)
        }
        .padding(DesignTokens.Spacing.xl)
        .background(WashBackground(slots: [.sky, .butter]))
    }
}
