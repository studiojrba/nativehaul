import Foundation

/// Searches IGDB for Switch games (ADR 0038). Live: ``IGDBClient``.
protocol IGDBSearching: Sendable {
    /// Switch and Switch 2 games named like `title`, or `nil` when IGDB can't be used (no credentials, or Twitch
    /// refused them). `nil` is not an error: the feature is simply absent.
    func searchSwitchGames(title: String) async throws -> [IGDBGame]?
}
