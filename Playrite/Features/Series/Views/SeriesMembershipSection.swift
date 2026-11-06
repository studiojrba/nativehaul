import SwiftUI

/// Detail-screen block: Up Next for each series containing the game.
struct SeriesMembershipSection: View {
    @State private var viewModel: SeriesMembershipViewModel

    /// Creates the section.
    init(viewModel: SeriesMembershipViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ForEach(viewModel.memberships, id: \.series.id) { membership in
            UpNextStrip(title: "Up Next in \(membership.series.name)", items: membership.upNext)
        }
    }
}

#Preview {
    let environment = AppEnvironment.preview
    if let game = try? environment.repository.fetchGames().last {
        SeriesMembershipSection(viewModel: environment.makeSeriesMembershipViewModel(for: game))
            .padding(DesignTokens.Spacing.lg)
    }
}
