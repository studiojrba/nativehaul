import SwiftUI

/// What couch shows (spec §3.7, ADR 0058): the desktop's screens mirrored at 10-foot scale under one focus model — the
/// backdrop follows the focused game, the header carries the status pill, the nav column slides in from the left, the
/// prompt bar follows focus, toasts and overlays sit on top. ``CouchRootView`` hosts it in the full-screen window.
struct CouchScreenStack: View {
    /// Couch's state.
    let viewModel: CouchViewModel

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let scale = viewModel.scale
        let tint = viewModel.tintGame
        ZStack(alignment: .topLeading) {
            CouchBackdrop(game: tint, palette: tint.map(viewModel.palette(for:)) ?? .neutral)
            screen
                .id(screenKey)
                .transition(.opacity)
            CouchHeader(viewModel: viewModel)
            if viewModel.state.area == .nav {
                CouchNavColumn(viewModel: viewModel)
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
            CouchPromptBarView(bar: viewModel.promptBar, family: viewModel.glyphFamily, scale: scale)
            if let toast = viewModel.toast {
                CouchToastView(toast: toast, scale: scale)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .allowsHitTesting(false)
            }
            CouchOverlayLayer(viewModel: viewModel)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onGeometryChange(for: CGSize.self) { $0.size } action: { viewModel.updateSize($0) }
        .animation(reduceMotion ? nil : Motion.settle(), value: viewModel.state.area)
        .animation(reduceMotion ? nil : Motion.fade, value: viewModel.state.screen)
        .animation(reduceMotion ? nil : Motion.fade, value: viewModel.state.overlay)
        .animation(reduceMotion ? nil : Motion.fade, value: viewModel.toast)
    }

    private var screenKey: String {
        viewModel.state.screen == .detail
            ? "detail-\(viewModel.state.detailGameID?.uuidString ?? "")"
            : viewModel.state.screen.rawValue
    }

    @ViewBuilder private var screen: some View {
        switch viewModel.state.screen {
        case .home: CouchHomeScreen(viewModel: viewModel)
        case .library: CouchLibraryScreen(viewModel: viewModel)
        case .detail: CouchDetailScreen(viewModel: viewModel)
        case .builds: CouchBuildsScreen(viewModel: viewModel)
        case .settings: CouchSettingsScreen(viewModel: viewModel)
        }
    }
}

#Preview {
    AppearancePreviewPair {
        CouchScreenStack(viewModel: .preview)
            .frame(width: CouchLayout.previewHalf.width, height: CouchLayout.previewHalf.height)
    }
}
