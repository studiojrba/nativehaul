import AppKit
import SwiftUI

/// An installed app's own icon, read from its bundle by macOS (the emulator's real icon).
struct AppIconImage: View {
    /// The `.app` path.
    let path: String

    var body: some View {
        Image(nsImage: NSWorkspace.shared.icon(forFile: path))
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .accessibilityHidden(true)
    }
}

#Preview {
    AppIconImage(path: "/System/Applications/Calculator.app")
        .frame(width: ShellLayout.OnboardingBuild.chip, height: ShellLayout.OnboardingBuild.chip)
        .padding(DesignTokens.Spacing.lg)
}
