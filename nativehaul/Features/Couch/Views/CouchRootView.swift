import SwiftUI

/// Couch mode (spec §3.7, ADR 0058): it takes the main window full screen over the desktop layout and hands the window
/// back when it closes. It hosts ``CouchScreenStack`` and owns the session: controller input (start/stop), the
/// development keyboard, the clock, couch's auto-advance rule and the focused game's palette.
struct CouchRootView: View {
    /// Couch's state.
    let viewModel: CouchViewModel

    @FocusState private var hasKeyFocus: Bool

    var body: some View {
        let tint = viewModel.tintGame
        CouchScreenStack(viewModel: viewModel)
            .background(CouchFullScreenWindow())
            .ignoresSafeArea()
            .focusable()
            .focused($hasKeyFocus)
            .focusEffectDisabled()
            .onKeyPress(phases: [.down, .repeat], action: handle)
            .onAppear {
                viewModel.start()
                hasKeyFocus = true
            }
            .onDisappear { viewModel.stop() }
            .task { await runClock() }
            .task(id: viewModel.autoAdvanceKey) { await viewModel.runAutoAdvance() }
            .task(id: tint?.id) {
                if let tint {
                    await viewModel.loadPalette(for: tint)
                }
            }
    }

    private func runClock() async {
        while !Task.isCancelled {
            viewModel.tick()
            try? await Task.sleep(for: .seconds(CouchInputTiming.clockRefresh))
        }
    }

    /// Development keys (never advertised): see ``CouchKeyboardMap``. Command shortcuts pass through to the menus.
    private func handle(_ press: KeyPress) -> KeyPress.Result {
        guard !press.modifiers.contains(.command), let key = Self.key(for: press),
              let input = CouchKeyboardMap.input(for: key)
        else { return .ignored }
        viewModel.handle(input)
        return .handled
    }

    private static func key(for press: KeyPress) -> CouchKeyboardMap.Key? {
        switch press.key {
        case .upArrow: .arrow(.up)
        case .downArrow: .arrow(.down)
        case .leftArrow: .arrow(.left)
        case .rightArrow: .arrow(.right)
        case .return: .returnKey
        case .escape: .escape
        case .delete: .delete
        default: press.characters.first.map(CouchKeyboardMap.Key.character)
        }
    }
}

#Preview {
    CouchRootView(viewModel: .preview)
        .frame(width: DesignTokens.Layout.windowMinWidth, height: DesignTokens.Layout.windowMinHeight)
}
