import SwiftData
import SwiftUI

/// Application entry point.
@main
struct PlayriteApp: App {
    private let launch: Result<AppEnvironment, Error>

    init() {
        launch = Result { try AppEnvironment.live() }
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
                }
            }
            .frame(minWidth: DesignTokens.Layout.windowMinWidth, minHeight: DesignTokens.Layout.windowMinHeight)
        }
        Settings {
            if case let .success(environment) = launch {
                SettingsView(environment: environment)
            }
        }
    }
}
