import SwiftUI

/// Shown when the persistent store cannot be opened.
struct LaunchFailureView: View {
    /// Description of what went wrong.
    let message: String

    var body: some View {
        ContentUnavailableView(
            "Playrite Could Not Open Its Library",
            systemImage: "exclamationmark.triangle",
            description: Text(message)
        )
        .padding(DesignTokens.Spacing.xxl)
    }
}

#Preview {
    LaunchFailureView(message: "The data store is unavailable.")
}
