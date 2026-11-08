import SwiftUI

/// Legal/safety note shown wherever the module is configured.
struct NXNativeDisclaimer: View {
    var body: some View {
        Label {
            Text("Optional module. Retriever does not include the nxnative engine, console keys, firmware or games. "
                + "You supply your own engine and your own legally obtained files.")
        } icon: {
            Image(systemName: "info.circle")
        }
        .font(DesignTokens.Typography.caption)
        .foregroundStyle(Theme.secondaryText)
    }
}

#Preview {
    NXNativeDisclaimer().padding(DesignTokens.Spacing.lg)
}
