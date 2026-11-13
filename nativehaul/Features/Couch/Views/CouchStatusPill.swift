import SwiftUI

/// The status pill (spec §3.7): a green dot (when a controller is connected) and "Controller connected" or
/// "No controller", a `·`, and the clock in tabular figures.
struct CouchStatusPill: View {
    /// "Controller connected" / "No controller".
    let status: String
    /// Whether a controller is connected (the dot is green, else muted).
    let isConnected: Bool
    /// `h:mm`.
    let clock: String
    /// The couch scale.
    let scale: CouchScale

    private typealias Metrics = CouchLayout.Header

    var body: some View {
        HStack(spacing: scale(Metrics.pillGap)) {
            Circle()
                .fill(isConnected ? Theme.readyDot : Theme.inkMute)
                .frame(width: scale(Metrics.dot), height: scale(Metrics.dot))
            Text(status)
            Text("·").foregroundStyle(Theme.inkMute)
            Text(clock).monospacedDigit()
        }
        .font(Typeface.sans(scale(Metrics.pillText)))
        .foregroundStyle(Theme.ink)
        .padding(.horizontal, scale(Metrics.pillHorizontal))
        .padding(.vertical, scale(Metrics.pillVertical))
        .frostedGlass()
        .elevation(.small)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    let scale = CouchScale(size: CGSize(width: DesignTokens.Layout.windowMinWidth, height: CouchLayout.referenceHeight))
    AppearancePreviewPair {
        VStack(spacing: DesignTokens.Spacing.md) {
            CouchStatusPill(status: "Controller connected", isConnected: true, clock: "9:41", scale: scale)
            CouchStatusPill(status: "No controller", isConnected: false, clock: "9:41", scale: scale)
        }
        .padding(DesignTokens.Spacing.xl)
    }
}
