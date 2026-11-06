import AppKit
import SwiftUI

/// Ready to sync: the account, Sync Now, and ways to undo the setup.
struct SteamReadyStep: View {
    /// Flow state.
    let viewModel: SteamConnectionViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SteamStageHeader(title: "Ready to sync", symbolName: "checkmark.circle")
            HStack(spacing: DesignTokens.Spacing.md) {
                avatar
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                    Text(viewModel.accountName).font(DesignTokens.Typography.headline)
                    Text("API key stored in Keychain").font(DesignTokens.Typography.caption)
                        .foregroundStyle(Theme.secondaryText)
                }
            }
            HStack(spacing: DesignTokens.Spacing.md) {
                Button("Sync Now", systemImage: "arrow.triangle.2.circlepath") { Task { await viewModel.syncNow() } }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isWorking)
                if viewModel.isWorking {
                    ProgressView().controlSize(.small)
                }
                if let summary = viewModel.lastSummary {
                    Text(summary.description).foregroundStyle(Theme.secondaryText)
                }
            }
            HStack(spacing: DesignTokens.Spacing.md) {
                Button("Sign Out") { viewModel.signOut() }
                Button("Remove Key", role: .destructive) { viewModel.removeKey() }
            }
        }
    }

    @ViewBuilder private var avatar: some View {
        if let data = viewModel.avatarData, let image = NSImage(data: data) {
            Image(nsImage: image).resizable().scaledToFill()
                .frame(width: DesignTokens.Layout.badgeSize, height: DesignTokens.Layout.badgeSize)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
                .accessibilityHidden(true)
        } else {
            Image(systemName: "person.crop.square")
                .font(DesignTokens.Typography.largeTitle)
                .foregroundStyle(Theme.secondaryText)
                .accessibilityHidden(true)
        }
    }
}

#Preview {
    let account = MockSteamAccountStore(configured: true)
    SteamReadyStep(viewModel: SteamConnectionViewModel(
        account: account,
        signIn: MockSteamSignInService(account: account),
        sync: MockSteamSyncService(isConfigured: true),
        opener: RecordingURLOpener()
    ))
    .padding(DesignTokens.Spacing.xl)
}
