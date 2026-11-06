import SwiftUI

/// A missing-file notice above the build queue when no engine exists anywhere Retriever looked (ADR 0021).
struct EngineNotFoundBanner: View {
    /// Opens the file picker.
    let onChooseEngine: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
            Image(systemName: "questionmark.folder")
                .foregroundStyle(Theme.secondaryText)
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(NXNativeReadiness.engineNotFoundTitle).font(DesignTokens.Typography.headline)
                Text(NXNativeReadiness.engineNotFoundMessage)
                    .foregroundStyle(Theme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: DesignTokens.Spacing.md)
            Button(NXNativeReadiness.chooseEngineTitle, action: onChooseEngine)
        }
        .padding(DesignTokens.Spacing.md)
        .background(Theme.surface)
    }
}

#Preview {
    EngineNotFoundBanner {}
}
