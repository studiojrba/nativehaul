import AppKit
import SwiftUI

/// The trailer slide (ADR 0038). While it is on screen it plays muted and loops, with pause and sound buttons.
/// Under Reduce Motion it never starts by itself: the poster shows with a play button. If the stream fails, the poster
/// stays and the play button goes away.
struct TrailerSlideView: View {
    /// Stream to play.
    let url: URL
    /// Cached poster still.
    let posterPath: String?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var model: TrailerPlayerModel?

    var body: some View {
        ZStack {
            Theme.mediaBackdrop
            if let poster = posterPath.flatMap(NSImage.init(contentsOfFile:)) {
                Image(nsImage: poster).resizable().scaledToFit()
            }
            if let model, !model.hasFailed {
                TrailerPlayerLayer(player: model.player)
            }
        }
        .overlay { startButton }
        .overlay(alignment: .bottomLeading) { playbackControls }
        .onAppear { follow(isVisible: true) }
        .onScrollVisibilityChange { follow(isVisible: $0) }
        .onDisappear { model?.pause() }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Trailer")
    }

    @ViewBuilder private var startButton: some View {
        if model == nil {
            Button("Play trailer", systemImage: "play.fill", action: start)
                .labelStyle(.iconOnly)
                .font(DesignTokens.Typography.largeTitle)
                .buttonStyle(.borderless)
                .padding(DesignTokens.Spacing.lg)
                .smokedGlass(in: Circle())
        }
    }

    @ViewBuilder private var playbackControls: some View {
        if let model, !model.hasFailed {
            HStack(spacing: DesignTokens.Spacing.sm) {
                Button(
                    model.isPlaying ? "Pause trailer" : "Play trailer",
                    systemImage: model.isPlaying ? "pause.fill" : "play.fill",
                    action: model.togglePlayback
                )
                Button(
                    model.isMuted ? "Turn sound on" : "Turn sound off",
                    systemImage: model.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill",
                    action: model.toggleMute
                )
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)
            .padding(DesignTokens.Spacing.sm)
            .smokedGlass(in: Capsule())
            .padding(DesignTokens.Spacing.md)
        }
    }

    /// Plays while on screen and pauses off screen, unless Reduce Motion is on (then only the player starts it).
    private func follow(isVisible: Bool) {
        if TrailerAutoplayPolicy.playsByItself(reduceMotion: reduceMotion, isVisible: isVisible) {
            start()
        } else if !isVisible {
            model?.pause()
        }
    }

    private func start() {
        let model = model ?? TrailerPlayerModel(url: url)
        self.model = model
        model.play()
    }
}

#Preview {
    if let url = URL(string: "https://example.com/trailer.m3u8") {
        TrailerSlideView(url: url, posterPath: nil)
            .frame(width: DesignTokens.Layout.detailMinWidth)
            .aspectRatio(DesignTokens.Media.fallbackAspect, contentMode: .fit)
    }
}
