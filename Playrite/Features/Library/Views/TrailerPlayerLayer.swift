import AVFoundation
import SwiftUI

/// An `AVPlayerLayer` with no system controls. The video fits its frame (never cropped, ADR 0038).
struct TrailerPlayerLayer: NSViewRepresentable {
    /// The player to show.
    let player: AVPlayer

    func makeNSView(context _: Context) -> NSView {
        let view = NSView()
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspect
        view.layer = layer
        view.wantsLayer = true
        return view
    }

    func updateNSView(_ view: NSView, context _: Context) {
        (view.layer as? AVPlayerLayer)?.player = player
    }
}

#Preview {
    TrailerPlayerLayer(player: AVPlayer())
        .frame(width: DesignTokens.Layout.detailMinWidth)
        .aspectRatio(DesignTokens.Media.fallbackAspect, contentMode: .fit)
}
