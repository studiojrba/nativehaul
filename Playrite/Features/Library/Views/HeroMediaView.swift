import AppKit
import SwiftUI

/// Wide hero/background slot at the top of the details centre. Falls back to the cover, then a placeholder.
struct HeroMediaView: View {
    /// Hero image path.
    let heroImagePath: String?
    /// Cover path used when there is no hero image.
    let coverImagePath: String?

    var body: some View {
        ZStack {
            Theme.placeholder
            if let image {
                Image(nsImage: image).resizable().scaledToFill()
            } else {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(DesignTokens.Typography.largeTitle)
                    .foregroundStyle(Theme.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: DesignTokens.Details.heroHeight)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg))
        .accessibilityHidden(true)
    }

    /// First readable image: hero, then cover.
    private var image: NSImage? {
        [heroImagePath, coverImagePath].compactMap(\.self).lazy.compactMap(NSImage.init(contentsOfFile:)).first
    }
}

#Preview {
    HeroMediaView(heroImagePath: nil, coverImagePath: nil)
        .padding(DesignTokens.Spacing.lg)
}
