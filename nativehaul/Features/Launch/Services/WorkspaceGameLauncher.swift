import AppKit
import Foundation

/// Live ``GameLaunching``: NSWorkspace for game apps and emulators.
///
/// `.app` launches go through NSWorkspace so the playtime watcher sees them like any other launch.
@MainActor
final class WorkspaceGameLauncher: GameLaunching {
    /// Creates the launcher.
    init() {}

    func launch(_ target: LaunchTarget, style: LaunchStyle) async throws {
        let planned = FullScreenLaunch.target(target, style: style)
        let environment = FullScreenLaunch.environment(style: style, infoPlist: planned.appPath.flatMap(Self.infoPlist))
        switch planned {
        case let .application(path):
            _ = try await NSWorkspace.shared.openApplication(
                at: URL(fileURLWithPath: path),
                configuration: Self.openConfiguration(arguments: nil, environment: environment)
            )
        case let .applicationWithArguments(path, arguments):
            _ = try await NSWorkspace.shared.openApplication(
                at: URL(fileURLWithPath: path),
                configuration: Self.openConfiguration(arguments: arguments, environment: environment)
            )
        }
    }

    /// How a game app is opened (ADR 0030): it is always activated, so it starts in front with the focus, and
    /// nativehaul never takes the focus back. A game launched with arguments gets its own instance. TV mode may add
    /// environment variables (ADR 0052); desktop launches add none.
    static func openConfiguration(
        arguments: [String]?,
        environment: [String: String] = [:]
    ) -> NSWorkspace.OpenConfiguration {
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        if let arguments {
            configuration.arguments = arguments
            configuration.createsNewApplicationInstance = true
        }
        if !environment.isEmpty {
            configuration.environment = environment
        }
        return configuration
    }

    private static func infoPlist(ofAppAt path: String) -> [String: Any]? {
        let url = URL(fileURLWithPath: path).appending(path: "Contents/Info.plist")
        return NSDictionary(contentsOf: url) as? [String: Any]
    }
}
