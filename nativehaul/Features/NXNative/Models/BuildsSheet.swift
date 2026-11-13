import Foundation

/// The sheet on show over the Builds page. One at a time, so picking a known issue moves straight to its fix.
enum BuildsSheet: Identifiable, Equatable {
    /// Add a build (folder-first).
    case addBuild
    /// Every documented issue.
    case knownIssues
    /// One issue's guided fix.
    case troubleshoot(TroubleshootingCase)

    /// Identity for `.sheet(item:)`.
    var id: String {
        switch self {
        case .addBuild: "add"
        case .knownIssues: "issues"
        case let .troubleshoot(entry): "case-\(entry.id)"
        }
    }
}
