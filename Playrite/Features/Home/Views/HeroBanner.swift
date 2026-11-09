import AppKit
import SwiftUI

/// A game's wide banner art filling the hero, with a dark scrim at the bottom so the title and data stay readable.
struct HeroBanner: View {
    /// The banner image.
    let imagePath: String?

    var body: some View {
        Theme.placeholder
            .overlay {
                if let image = imagePath.flatMap(NSImage.init(contentsOfFile:)) {
                    Image(nsImage: image).resizable().scaledToFill()
                }
            }
            .overlay {
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: DesignTokens.Home.scrimStart),
                        .init(color: Theme.artworkScrim.opacity(DesignTokens.Home.scrimOpacity), location: 1),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .clipped()
            .accessibilityHidden(true)
    }
}

#Preview {
    HeroBanner(imagePath: nil)
        .frame(height: EnergyLevel.of(.leanedIn).heroHeight)
}
