import SwiftUI

/// The title block of a mirrored couch screen (Library, Builds, Settings): an eyebrow, a display title and a line.
struct CouchPageHeader: View {
    /// The eyebrow.
    let eyebrow: String
    /// The title.
    let title: String
    /// The line under it, if any.
    var subtitle: String?
    /// The couch scale.
    let scale: CouchScale

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Eyebrow(eyebrow, size: scale(CouchLayout.Page.eyebrow))
            DisplayHeadline(lead: title, size: scale(CouchLayout.Page.title), isTrailingAccented: title.hasSuffix("."))
            if let subtitle {
                Text(subtitle)
                    .font(Typeface.sans(scale(CouchLayout.Page.subtitle)))
                    .foregroundStyle(Theme.inkSoft)
                    .padding(.top, scale(CouchLayout.Page.subtitleTop))
            }
        }
    }
}

#Preview {
    let scale = CouchScale(size: CGSize(width: DesignTokens.Layout.windowMinWidth, height: CouchLayout.referenceHeight))
    AppearancePreviewPair {
        CouchPageHeader(eyebrow: "Library", title: "Your shelf.", subtitle: "18 games, A–Z", scale: scale)
            .padding(DesignTokens.Spacing.xl)
    }
}
