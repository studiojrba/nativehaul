import SwiftUI

/// The slim top bar: the shelf name on the left, the controller and the clock on the right.
struct TVTopBar: View {
    /// Left-hand title.
    let title: String
    /// The controller in use.
    let family: ControllerFamily
    /// Screen metrics.
    let metrics: TVMetrics

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title).font(metrics.titleFont)
            Spacer()
            Label(family.displayName, systemImage: family == .keyboard ? "keyboard" : "gamecontroller")
                .font(metrics.bodyFont)
                .foregroundStyle(Theme.secondaryText)
            TimelineView(.everyMinute) { context in
                Text(context.date, format: .dateTime.hour().minute())
                    .font(metrics.bodyEmphasisFont)
                    .monospacedDigit()
            }
            .padding(.leading, metrics.gap)
        }
        .foregroundStyle(Theme.primaryText)
    }
}

#Preview {
    TVTopBar(title: "Switch", family: .nintendo, metrics: TVMetrics(size: DesignTokens.TVMode.previewScreen))
        .padding(DesignTokens.Spacing.xl)
}
