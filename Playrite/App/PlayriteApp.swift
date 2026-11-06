import SwiftUI

/// Application entry point.
@main
struct PlayriteApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .frame(
                    minWidth: DesignTokens.Layout.windowMinWidth,
                    minHeight: DesignTokens.Layout.windowMinHeight
                )
        }
    }
}
