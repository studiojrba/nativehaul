import SwiftUI

/// Whatever covers couch's screens (spec §3.7): the launch phase, Resume/Close, the closing wait, the force-quit offer
/// (with its unsaved-progress warning) or a message.
struct CouchOverlayLayer: View {
    /// Couch's state.
    let viewModel: CouchViewModel

    var body: some View {
        let scale = viewModel.scale
        let family = viewModel.glyphFamily
        let game = viewModel.sessionGame
        let short = game.map { ShortTitle.make(from: $0.title) } ?? "Your game"
        switch viewModel.state.overlay {
        case .none:
            EmptyView()
        case .launching:
            if let game {
                CouchLaunchPhase(game: game, palette: viewModel.palette(for: game), scale: scale)
            }
        case let .paused(choice):
            CouchOverlayCard(
                game: game,
                eyebrow: "Paused",
                title: short,
                buttons: ["Resume", "Close game"],
                focusedButton: choice == .resume ? 0 : 1,
                prompts: [
                    CouchPrompt(buttons: [.select], label: "Select"),
                    CouchPrompt(buttons: [.back], label: "Resume"),
                ],
                family: family,
                scale: scale
            )
        case .closing:
            CouchOverlayCard(
                game: game,
                eyebrow: "Closing",
                title: short,
                message: CouchCopy.closing(short),
                family: family,
                scale: scale
            )
        case let .forceQuitOffer(choice):
            CouchOverlayCard(
                game: game,
                eyebrow: "Still running",
                title: short,
                message: CouchCopy.forceQuitWarning(short),
                buttons: ["Keep waiting", "Force quit"],
                focusedButton: choice == .keepWaiting ? 0 : 1,
                prompts: [
                    CouchPrompt(buttons: [.select], label: "Select"),
                    CouchPrompt(buttons: [.back], label: "Keep waiting"),
                ],
                family: family,
                scale: scale
            )
        case let .message(text):
            CouchOverlayCard(
                game: nil,
                eyebrow: "Couldn't start the game",
                title: "Not this time",
                message: text,
                prompts: [CouchPrompt(buttons: [.select], label: "OK")],
                family: family,
                scale: scale
            )
        }
    }
}

#Preview {
    let viewModel = CouchViewModel.preview
    viewModel.state.overlay = .forceQuitOffer(.keepWaiting)
    return CouchOverlayLayer(viewModel: viewModel)
        .frame(width: DesignTokens.Layout.windowMinWidth, height: DesignTokens.Layout.windowMinHeight)
}
