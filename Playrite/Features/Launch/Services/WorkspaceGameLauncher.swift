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
            let configuration = NSWorkspace.OpenConfiguration()
            configuration.activates = true
            _ = try await NSWorkspace.shared.openApplication(
                at: URL(fileURLWithPath: path),
                configuration: configuration
            )
        case let .applicationWithArguments(path, arguments):
            let configuration = NSWorkspace.OpenConfiguration()
            configuration.activates = true
            configuration.arguments = arguments
            configuration.createsNewApplicationInstance = true
            _ = try await NSWorkspace.shared.openApplication(
                at: URL(fileURLWithPath: path),
                configuration: configuration
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
}
