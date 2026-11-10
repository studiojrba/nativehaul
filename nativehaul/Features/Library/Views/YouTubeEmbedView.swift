import SwiftUI
import WebKit

/// YouTube's IFrame player in a web view (ADR 0038). Muted autoplay is allowed without a click; YouTube's own controls
/// handle pause and sound.
struct YouTubeEmbedView: NSViewRepresentable {
    /// Video to play.
    let videoID: String

    func makeNSView(context _: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.mediaTypesRequiringUserActionForPlayback = []
        let view = WKWebView(frame: .zero, configuration: configuration)
        view.loadHTMLString(YouTubeEmbed.html(videoID: videoID, autoplay: true), baseURL: YouTubeEmbed.baseURL)
        return view
    }

    func updateNSView(_: WKWebView, context _: Context) {}
}

#Preview {
    YouTubeEmbedView(videoID: "aaaaaaaaaaa")
        .frame(width: DesignTokens.Layout.detailMinWidth)
        .aspectRatio(DesignTokens.Media.fallbackAspect, contentMode: .fit)
}
