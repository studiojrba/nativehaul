import SwiftUI

/// A calm couch empty state: a display title and a line, centred.
struct CouchEmptyState: View {
    /// The title.
    let title: String
    /// The line under it.
    let message: String
    /// The couch scale.
    let scale: CouchScale

    var body: some View {
        VStack(spacing: scale(CouchLayout.Page.subtitleTop)) {
            Text(title)
                .font(Typeface.display(scale(CouchLayout.Page.title)))
                .foregroundStyle(Theme.ink)
            Text(message)
                .font(Typeface.sans(scale(CouchLayout.Page.subtitle)))
                .foregroundStyle(Theme.inkSoft)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    let scale = CouchScale(size: CGSize(width: DesignTokens.Layout.windowMinWidth, height: CouchLayout.referenceHeight))
    AppearancePreviewPair {
        CouchEmptyState(title: "Nothing in the oven", message: "Builds show up here.", scale: scale)
            .frame(height: CouchLayout.previewHalf.height)
    }
}
