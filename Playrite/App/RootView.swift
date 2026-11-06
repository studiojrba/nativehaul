import SwiftUI

/// Top-level view. Placeholder until the library feature lands.
struct RootView: View {
    var body: some View {
        Text(AppInfo.productName)
            .font(DesignTokens.Typography.largeTitle)
            .padding(DesignTokens.Spacing.xl)
    }
}

#Preview {
    RootView()
}
