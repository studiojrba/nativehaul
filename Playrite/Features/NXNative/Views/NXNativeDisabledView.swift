import SwiftUI

/// Shown until the user enables and configures the module.
struct NXNativeDisabledView: View {
    var body: some View {
        ContentUnavailableView {
            Label("NXNative Module Off", systemImage: "hammer")
        } description: {
            VStack(spacing: DesignTokens.Spacing.md) {
                Text("Enable the module and choose your own engine in Settings to build native apps.")
                NXNativeDisclaimer()
            }
        } actions: {
            SettingsLink { Text("Open Settings…") }
        }
    }
}

#Preview {
    NXNativeDisabledView()
}
