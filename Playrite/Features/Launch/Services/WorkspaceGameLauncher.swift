import AppKit
import Foundation

/// Live ``GameLaunching``: NSWorkspace for apps and URLs, `Process` for CrossOver.
///
/// `.app` launches go through NSWorkspace so the playtime watcher sees them like any other launch.
@MainActor
final class WorkspaceGameLauncher: GameLaunching {
    /// Creates the launcher.
    init() {}

    func launch(_ target: LaunchTarget) async throws {
        switch target {
        case let .application(path):
            _ = try await NSWorkspace.shared.openApplication(
                at: URL(fileURLWithPath: path),
                configuration: Self.openConfiguration(arguments: nil)
            )
        case let .applicationWithArguments(path, arguments):
            _ = try await NSWorkspace.shared.openApplication(
                at: URL(fileURLWithPath: path),
                configuration: Self.openConfiguration(arguments: arguments)
            )
        case let .url(url):
            guard NSWorkspace.shared.open(url) else { throw LaunchError.noHandler(url.absoluteString) }
        case let .process(executable, arguments):
            guard FileManager.default.isExecutableFile(atPath: executable) else {
                throw LaunchError.missingExecutable(executable)
            }
            let process = Process()
            process.executableURL = URL(fileURLWithPath: executable)
            process.arguments = arguments
            try process.run()
        }
    }

    /// How a game app is opened (ADR 0030): it is always activated, so it starts in front with the focus, and
    /// NX Shelf never takes the focus back. A game launched with arguments gets its own instance.
    static func openConfiguration(arguments: [String]?) -> NSWorkspace.OpenConfiguration {
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        if let arguments {
            configuration.arguments = arguments
            configuration.createsNewApplicationInstance = true
        }
        return configuration
    }
}
