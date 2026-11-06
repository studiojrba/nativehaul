import SwiftUI

/// Horizontal strip of every remaining series entry in true order.
struct UpNextStrip: View {
    /// Strip title.
    let title: String
    /// Remaining items.
    let items: [UpNextItem]

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            SectionHeader(title: title, caption: items.isEmpty ? nil : "\(items.count) remaining")
            if items.isEmpty {
                Label("Series complete", systemImage: "checkmark.seal").foregroundStyle(Theme.success)
            } else {
                FlowLayout(spacing: DesignTokens.Spacing.lg) {
                    ForEach(items) { UpNextCard(item: $0) }
                }
            }
        }
    }
}

#Preview {
    UpNextStrip(title: "Up Next", items: [
        UpNextItem(id: UUID(), partLabel: "2", title: "Lantern II", status: .backlog, isNext: true),
        UpNextItem(id: UUID(), partLabel: "3", title: "Lantern III", status: nil, isNext: false),
    ])
    .padding(DesignTokens.Spacing.lg)
}
