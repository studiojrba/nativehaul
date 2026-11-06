import SwiftUI

/// Explains a Steam setup problem in plain words. For private game details it names the exact settings to change.
struct SteamNoticeView: View {
    /// The problem.
    let notice: SteamSetupNotice
    /// Opens Steam's privacy settings.
    let openPrivacySettings: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            switch notice {
            case .privateGameDetails:
                Label("Your Steam game details are private", systemImage: "eye.slash")
                    .font(DesignTokens.Typography.headline)
                Text("Steam won't share your games or playtime while they're private, even with a key.")
                Text("In Steam's privacy settings, under My Profile, set \u{201C}Game details\u{201D} to "
                    + "\u{201C}Public\u{201D}. Also untick \u{201C}Always keep my total playtime private\u{201D} "
                    + "so playtime can sync. Then press Sync Now again.")
                Button("Open Steam Privacy Settings", systemImage: "arrow.up.right.square", action: openPrivacySettings)
            case .keyRejected:
                Label("Steam didn't accept that key", systemImage: "key.slash")
                    .font(DesignTokens.Typography.headline)
                Text("It was not kept. Copy the key again from the Steam API key page and paste the whole thing.")
            case let .message(text):
                Label(text, systemImage: "exclamationmark.triangle")
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(DesignTokens.Spacing.md)
        .background(Theme.warning.opacity(DesignTokens.Opacity.subtle), in: RoundedRectangle(
            cornerRadius: DesignTokens.Radius.md
        ))
    }
}

#Preview {
    SteamNoticeView(notice: .privateGameDetails) {}
        .padding(DesignTokens.Spacing.lg)
}
