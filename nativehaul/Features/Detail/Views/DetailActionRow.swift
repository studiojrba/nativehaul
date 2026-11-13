import SwiftUI

/// Detail's actions (spec §3.3): Play / Start in ember (other ways to play in a small menu beside it), the favourite
/// heart, and Show in Finder. They wrap on a narrow column.
struct DetailActionRow: View {
    /// Detail's state.
    let viewModel: DetailViewModel
    /// Plays the game (the default route when `nil`).
    let play: (LaunchOption?) -> Void

    var body: some View {
        let options = viewModel.launch.availability.options
        FlowLayout(spacing: ShellLayout.Detail.actionsGap) {
            Button { play(nil) } label: {
                HStack(spacing: KitMetrics.PillButton.gap) {
                    Image(systemName: "play.fill")
                        .font(.system(size: KitMetrics.PillButton.iconSize))
                    Text(viewModel.playLabel)
                }
            }
            .buttonStyle(EmberButtonStyle())
            .disabled(viewModel.launch.primaryOption == nil)
            .opacity(viewModel.launch.primaryOption == nil ? DesignTokens.Opacity.disabled : 1)
            if options.count > 1 {
                otherRoutes(options)
            }
            FavoriteToggleButton(isOn: viewModel.isFavorite) { viewModel.toggleFavorite() }
            if viewModel.finderPath != nil {
                Button { viewModel.showInFinder() } label: {
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        Image(systemName: "folder")
                            .font(.system(size: ShellLayout.Detail.folderIcon))
                        Text("Show in Finder")
                            .font(Typeface.sans(TypeStyle.Size.body))
                    }
                    .foregroundStyle(Theme.inkSoft)
                }
                .buttonStyle(SurfacePillButtonStyle())
            }
        }
    }

    /// Other routes (another emulator that runs the game, …).
    private func otherRoutes(_ options: [LaunchOption]) -> some View {
        Menu {
            ForEach(options) { option in
                Button(option.title) { play(option) }
            }
        } label: {
            Image(systemName: "chevron.down")
                .font(.system(size: ShellLayout.Detail.heartSize))
                .foregroundStyle(Theme.ink)
                .frame(width: ShellLayout.Detail.favouriteSize, height: ShellLayout.Detail.favouriteSize)
                .background(Circle().fill(Theme.surface.opacity(KitMetrics.PillButton.surfaceOpacity)))
                .elevation(.small)
        }
        .menuStyle(.button)
        .menuIndicator(.hidden)
        .buttonStyle(PressButtonStyle())
        .fixedSize()
        .accessibilityLabel("Other ways to play")
    }
}

#Preview {
    let environment = AppEnvironment.preview
    if let game = try? environment.repository.fetchGames().first {
        AppearancePreviewPair {
            DetailActionRow(
                viewModel: environment.makeDetailViewModel(for: game, buildBadge: { nil }, library: { [] }),
                play: { _ in }
            )
            .padding(DesignTokens.Spacing.xl)
        }
    }
}
