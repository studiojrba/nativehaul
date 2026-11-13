import SwiftData
import SwiftUI

/// Application entry point.
@main
struct NativehaulApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    private let launch: Result<AppEnvironment, Error>?

    /// `true` when the app is only hosting unit tests: it then starts nothing live, so tests never touch the user's
    /// library or folders (tests use mocks only).
    private static var isHostingTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    private var appUpdater: (any AppUpdating)? {
        if case let .success(environment) = launch {
            environment.appUpdater
        } else {
            nil
        }
    }

    private var appearance: AppearanceController? {
        if case let .success(environment) = launch {
            environment.appearance
        } else {
            nil
        }
    }

    init() {
        #if DEBUG
            if let request = ScreenshotRequest.current, !Self.isHostingTests {
                launch = Result { try ScreenshotHarness.environment(for: request) }
                return
            }
        #endif
        launch = Self.isHostingTests ? nil : Result { try AppEnvironment.live() }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                switch launch {
                case let .success(environment):
                    RootView(environment: environment)
                        .modelContainer(environment.container)
                case let .failure(error):
                    LaunchFailureView(message: error.localizedDescription)
                case nil:
                    EmptyView()
                }
            }
            .frame(minWidth: DesignTokens.Layout.windowMinWidth, minHeight: DesignTokens.Layout.windowMinHeight)
            .background(Theme.canvas)
            .tint(Theme.accent)
            .font(DesignTokens.Typography.body)
            .preferredColorScheme(appearance?.colorScheme)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            ShellCommands()
            CheckForUpdatesCommands(updater: appUpdater)
        }
    }
}
