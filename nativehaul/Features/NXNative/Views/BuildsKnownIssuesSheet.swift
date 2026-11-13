import SwiftUI

/// Every documented build issue, from the Builds tools (ADR 0056). Picking one opens its guided, reversible fix.
struct BuildsKnownIssuesSheet: View {
    /// The cases.
    let cases: [TroubleshootingCase]
    /// Opens a case.
    let open: (TroubleshootingCase) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            KnowledgeBaseView(cases: cases, onOpen: open)
                .padding(DesignTokens.Spacing.xl)
        }
        .frame(minWidth: DesignTokens.Layout.detailMinWidth, minHeight: DesignTokens.Layout.windowMinHeight)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
        }
    }
}

#Preview {
    BuildsKnownIssuesSheet(cases: BundledKnowledgeBase().cases()) { _ in }
}
