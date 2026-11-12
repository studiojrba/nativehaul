import SwiftUI

/// The Start/Options menu panel (ADR 0052): TV options, audio output, Sleep, Restart, Shut Down and Exit TV Mode. A
/// power action asks for confirmation in the same panel.
struct TVMenuView: View {
    /// Rows.
    let items: [TVMenuItem]
    /// The highlighted row.
    let selectedIndex: Int
    /// A power action awaiting confirmation, if any.
    let confirming: TVPowerAction?
    /// Screen metrics.
    let metrics: TVMetrics

    var body: some View {
        VStack(alignment: .leading, spacing: metrics.gap) {
            if let confirming {
                Text(confirming.confirmation)
                    .font(metrics.bodyEmphasisFont)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text("Menu").font(metrics.titleFont)
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    row(item, isSelected: index == selectedIndex)
                }
            }
        }
        .padding(metrics.doubleGap)
        .frame(width: metrics.menuWidth, alignment: .leading)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: metrics.tileRadius))
        .foregroundStyle(Theme.primaryText)
    }

    private func row(_ item: TVMenuItem, isSelected: Bool) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(item.title).font(metrics.bodyEmphasisFont)
            if let note = item.note {
                Text(note).font(metrics.bodyFont).foregroundStyle(Theme.secondaryText)
            }
        }
        .padding(.vertical, metrics.halfGap)
        .padding(.horizontal, metrics.gap)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isSelected ? Theme.surfaceRaised : .clear, in: RoundedRectangle(cornerRadius: metrics.tileRadius))
        .foregroundStyle(isSelected ? Theme.primaryText : Theme.secondaryText)
    }
}

#Preview {
    TVMenuView(
        items: [.layout(.shelf), .audioOutput("TV Speakers"), .power(.sleep), .exitTVMode],
        selectedIndex: 1,
        confirming: nil,
        metrics: TVMetrics(size: DesignTokens.TVMode.previewScreen)
    )
    .padding(DesignTokens.Spacing.xxl)
}
