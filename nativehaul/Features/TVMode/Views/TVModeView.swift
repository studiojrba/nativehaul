import SwiftUI

/// TV (couch) mode's full-screen shell (ADR 0052): backdrop art, a slim top bar, the library (shelves or grid) or a
/// game's details, the Start/Options menu, and controller-matched prompts. A controller or the keyboard drives it.
struct TVModeView: View {
    @State private var viewModel: TVModeViewModel
    @State private var input: any TVInputProviding
    @FocusState private var hasKeyboardFocus: Bool

    /// Creates the view with its state and a controller input source.
    init(viewModel: TVModeViewModel, input: any TVInputProviding) {
        _viewModel = State(initialValue: viewModel)
        _input = State(initialValue: input)
    }

    var body: some View {
        GeometryReader { proxy in
            let metrics = TVMetrics(size: proxy.size)
            ZStack {
                TVBackdropView(game: viewModel.focusedGame)
                VStack(alignment: .leading, spacing: metrics.gap) {
                    TVTopBar(title: title, family: viewModel.family, metrics: metrics)
                    content(metrics)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    if let message = viewModel.message {
                        Text(message)
                            .font(metrics.bodyFont)
                            .foregroundStyle(Theme.warning)
                    }
                    TVPromptBar(prompts: viewModel.prompts, family: viewModel.family, metrics: metrics)
                }
                .padding(.horizontal, metrics.horizontalInset)
                .padding(.vertical, metrics.verticalInset)
                if isMenuShown {
                    Theme.artworkScrim.opacity(DesignTokens.Opacity.overlay)
                    TVMenuView(
                        items: viewModel.menuItems,
                        selectedIndex: viewModel.menuIndex,
                        confirming: confirming,
                        metrics: metrics
                    )
                }
            }
        }
        .ignoresSafeArea()
        .focusable()
        .focusEffectDisabled()
        .focused($hasKeyboardFocus)
        .onKeyPress(phases: .down) { press in
            guard let command = Self.command(for: press) else { return .ignored }
            send(command)
            return .handled
        }
        .onAppear {
            hasKeyboardFocus = true
            viewModel.reload()
            input.onInput = { send($0) }
            input.onFamilyChange = { viewModel.setFamily($0) }
            input.start()
        }
        .onDisappear { input.stop() }
    }

    @ViewBuilder private func content(_ metrics: TVMetrics) -> some View {
        if viewModel.shelves.isEmpty {
            Text("No games yet. Add a games folder in desktop mode and they'll appear here.")
                .font(metrics.bodyFont)
                .foregroundStyle(Theme.secondaryText)
        } else if viewModel.screen == .detail, let game = viewModel.focusedGame {
            TVDetailView(game: game, metrics: metrics)
        } else if viewModel.layout == .grid {
            TVGridView(viewModel: viewModel, metrics: metrics)
        } else {
            TVShelvesView(viewModel: viewModel, metrics: metrics)
        }
    }

    private var title: String {
        guard viewModel.layout == .grid, viewModel.shelves.indices.contains(viewModel.focus.shelf) else {
            return "nativehaul"
        }
        return viewModel.shelves[viewModel.focus.shelf].title
    }

    private var isMenuShown: Bool {
        switch viewModel.screen {
        case .menu, .confirm: true
        case .library, .detail: false
        }
    }

    private var confirming: TVPowerAction? {
        if case let .confirm(action) = viewModel.screen {
            action
        } else {
            nil
        }
    }

    private func send(_ command: TVInput) {
        NSCursor.setHiddenUntilMouseMoves(true)
        Task { await viewModel.handle(command) }
    }

    /// Keyboard controls: arrows move, Return plays, Esc goes back, Space opens details, Tab / Shift-Tab switch
    /// shelves, comma and period jump by letter, M opens the menu.
    static func command(for press: KeyPress) -> TVInput? {
        if press.key == .tab {
            return press.modifiers.contains(.shift) ? .previousShelf : .nextShelf
        }
        return keyCommands[press.key] ?? characterCommands[press.characters.lowercased()]
    }

    private static let keyCommands: [KeyEquivalent: TVInput] = [
        .upArrow: .move(.up), .downArrow: .move(.down), .leftArrow: .move(.left), .rightArrow: .move(.right),
        .return: .confirm, .escape: .back, .space: .details,
    ]

    private static let characterCommands: [String: TVInput] = [",": .previousLetter, ".": .nextLetter, "m": .menu]
}

#Preview {
    TVModeView(viewModel: AppEnvironment.preview.makeTVModeViewModel(), input: MockTVInputSource())
        .frame(width: DesignTokens.TVMode.previewThumbnail.width, height: DesignTokens.TVMode.previewThumbnail.height)
}
