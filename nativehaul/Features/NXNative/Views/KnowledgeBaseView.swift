import SwiftUI

/// Browsable list of documented troubleshooting cases.
struct KnowledgeBaseView: View {
    /// Cases.
    let cases: [TroubleshootingCase]
    /// Opens a case.
    let onOpen: (TroubleshootingCase) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            SectionHeader(title: "Troubleshooting Knowledge Base", caption: "\(cases.count) documented")
            ForEach(cases) { entry in
                Button {
                    onOpen(entry)
                } label: {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                        Text(entry.title).font(DesignTokens.Typography.headline)
                        Text(entry.symptom).font(DesignTokens.Typography.caption).foregroundStyle(Theme.secondaryText)
                            .lineLimit(DesignTokens.Lines.title)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    KnowledgeBaseView(cases: BundledKnowledgeBase().cases()) { _ in }
        .padding(DesignTokens.Spacing.lg)
}
