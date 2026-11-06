import SwiftUI

/// Row for a recently played Steam game. Figures are labelled SteamSynced.
struct SteamRecentGameRow: View {
    private static let secondsPerMinute = 60
    /// The game.
    let game: SteamRecentGame

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            Text(game.name ?? "App \(game.appid)").font(DesignTokens.Typography.headline)
            Spacer(minLength: DesignTokens.Spacing.none)
            if let recent = game.playtime2Weeks {
                Text("\(DurationFormatting.compact(seconds: recent * Self.secondsPerMinute)) last 2 weeks")
                    .foregroundStyle(Theme.secondaryText)
            }
            PlaytimeSourceTag(source: .steamSynced)
        }
    }
}

#Preview {
    SteamRecentGameRow(game: SteamRecentGame(
        appid: 1,
        name: "Skyward Lanterns",
        playtime2Weeks: 90,
        playtimeForever: 600
    ))
    .padding(DesignTokens.Spacing.lg)
}
