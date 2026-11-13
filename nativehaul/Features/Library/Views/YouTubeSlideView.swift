import AppKit
import SwiftUI

/// A YouTube trailer slide (ADR 0038). While on screen, YouTube's player plays it muted and looping. Off screen the
/// player is removed (which stops it) and the poster shows. Under Reduce Motion it never starts by itself: the poster
/// shows with a play button.
struct YouTubeSlideView: View {
    /// Video to play.
    let videoID: String
    /// Cached poster still.
    let posterPath: String?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPlayerShown = false

    var body: some View {
        ZStack {
            Theme.mediaBackdrop
            if let poster = posterPath.flatMap(NSImage.init(contentsOfFile:)) {
                Image(nsImage: poster).resizable().scaledToFit()
            }
            if isPlayerShown {
                YouTubeEmbedView(videoID: videoID)
            } else {
                Button("Play trailer", systemImage: "play.fill") { isPlayerShown = true }
                    .labelStyle(.iconOnly)
                    .font(DesignTokens.Typography.largeTitle)
                    .buttonStyle(.borderless)
                    .padding(DesignTokens.Spacing.lg)
                    .smokedGlass(in: Circle())
            }
        }
        .onAppear { follow(isVisible: true) }
        .onScrollVisibilityChange { follow(isVisible: $0) }
        .onDisappear { isPlayerShown = false }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Trailer")
    }

    private func follow(isVisible: Bool) {
        if TrailerAutoplayPolicy.playsByItself(reduceMotion: reduceMotion, isVisible: isVisible) {
            isPlayerShown = true
        } else if !isVisible {
            isPlayerShown = false
        }
    }
}

#Preview {
    YouTubeSlideView(videoID: "aaaaaaaaaaa", posterPath: nil)
        .frame(width: DesignTokens.Layout.detailMinWidth)
        .aspectRatio(DesignTokens.Media.fallbackAspect, contentMode: .fit)
}
