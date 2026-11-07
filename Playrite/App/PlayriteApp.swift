import SwiftData
import SwiftUI

/// Application entry point.
@main
struct PlayriteApp: App {
    private let launch: Result<AppEnvironment, Error>?

    /// `true` when the app is only hosting unit tests: it then starts nothing live, so tests never touch the user's
    /// library, folders or Downloads (tests use mocks only).
    private static var isHostingTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    init() {
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
        }
        Settings {
            if case let .success(environment) = launch {
                SettingsView(environment: environment)
            }
        }
    }
}
