import AppKit
import SwiftUI

/// Full-screen art behind TV mode: the focused game's hero (or cover) under a dark scrim, so text stays readable.
struct TVBackdropView: View {
    /// The focused game, if any.
    let game: Game?

    var body: some View {
        ZStack {
            Theme.canvas
            if let path = game?.heroImagePath ?? game?.coverImagePath, let image = NSImage(contentsOfFile: path) {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
                    .transition(.opacity)
                    .id(path)
            }
            LinearGradient(
                colors: [
                    Theme.artworkScrim.opacity(DesignTokens.TVMode.backdropScrimOpacity),
                    Theme.canvas,
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
    TVBackdropView(game: Game(title: "Tideborn"))
        .frame(width: DesignTokens.TVMode.previewThumbnail.width, height: DesignTokens.TVMode.previewThumbnail.height)
}
