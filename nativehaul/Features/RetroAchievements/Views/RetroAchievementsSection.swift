import SwiftUI

/// RetroAchievements on an emulated game's page (ADR 0047): progress and the set, earned first in colour, the rest
/// greyed. Absent entirely without credentials or for a system nativehaul can't identify; no nagging.
struct RetroAchievementsSection: View {
    @State private var viewModel: RetroAchievementsViewModel

    /// Creates the section.
    init(viewModel: RetroAchievementsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.isShown {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    SectionHeader(title: "RetroAchievements", caption: caption)
                    content
                }
            }
        }
        .task { await viewModel.load() }
    }

    private var caption: String {
        guard case let .found(progress) = viewModel.lookup else { return "" }
        let points = progress.points
        return "\(progress.earned) of \(progress.total) · \(points.earned) of \(points.total) points"
    }

    @ViewBuilder private var content: some View {
        switch viewModel.lookup {
        case let .found(progress):
            ForEach(progress.achievements) { achievement in
                HStack(spacing: DesignTokens.Spacing.md) {
                    AsyncImage(url: achievement.badgeURL) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        Theme.placeholder
                    }
                    .frame(
                        width: DesignTokens.RetroAchievements.badgeSize,
                        height: DesignTokens.RetroAchievements.badgeSize
                    )
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                        Text(achievement.title).font(DesignTokens.Typography.headline)
                        Text(achievement.description)
                            .font(DesignTokens.Typography.caption)
                            .foregroundStyle(Theme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: DesignTokens.Spacing.none)
                    Text("\(achievement.points)")
                        .font(DesignTokens.Typography.monospacedSmall)
                        .foregroundStyle(Theme.secondaryText)
                }
                .opacity(achievement.isEarned ? 1 : DesignTokens.Opacity.muted)
            }
        case .notFound:
            Text("This ROM isn't in RetroAchievements' list for its system.").foregroundStyle(Theme.secondaryText)
        case .failed:
            Text("RetroAchievements didn't answer. Try again later.").foregroundStyle(Theme.secondaryText)
        case .unavailable, .unsupportedSystem, nil:
            EmptyView()
        }
    }
}

#Preview {
    let environment = AppEnvironment.preview
    if let game = try? environment.repository.fetchGames().first {
        RetroAchievementsSection(viewModel: RetroAchievementsViewModel(
            game: game,
            service: MockRetroAchievementsService(result: .notFound),
            repository: environment.repository
        ))
        .padding(DesignTokens.Spacing.lg)
    }
}
