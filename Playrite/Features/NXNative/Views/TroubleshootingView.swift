import SwiftUI

/// Guided, reversible fix for one documented case.
struct TroubleshootingView: View {
    @State private var viewModel: TroubleshootingViewModel
    @Environment(\.dismiss) private var dismiss

    /// Creates the view.
    init(viewModel: TroubleshootingViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        let session = viewModel.session
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                Text(session.troubleshootingCase.title).font(DesignTokens.Typography.title)
                LabeledValueRow(label: "Symptom") { Text(session.troubleshootingCase.symptom) }
                LabeledValueRow(label: "Cause") { Text(session.troubleshootingCase.cause) }
                LabeledValueRow(label: "Engine script") {
                    Text(session.scriptPath).font(DesignTokens.Typography.monospacedSmall)
                }
                patchEditor
                ForEach(session.troubleshootingCase.steps) { step in
                    TroubleshootingStepRow(step: step, state: session.state(of: step), preview: session.preview(step)) {
                        viewModel.run(step)
                    }
                }
                HStack(spacing: DesignTokens.Spacing.md) {
                    Button("Revert Patch (restore backup)") { viewModel.revertPatch() }.disabled(session.backup == nil)
                    if session.isComplete {
                        Label("Case closed — script verified", systemImage: "checkmark.seal")
                            .foregroundStyle(Theme.success)
                    }
                }
                AuditLogView(entries: viewModel.auditEntries)
            }
            .padding(DesignTokens.Spacing.xl)
        }
        .frame(minWidth: DesignTokens.Layout.detailMinWidth, minHeight: DesignTokens.Layout.windowMinHeight)
        .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Close") { dismiss() } } }
    }

    private var patchEditor: some View {
        @Bindable var session = viewModel.session
        return VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            SectionHeader(title: "Patch", caption: "edit to match your engine's script; must match exactly once")
            TextField("Search text", text: $session.patch.search, axis: .vertical)
                .font(DesignTokens.Typography.monospacedSmall)
            TextField("Replacement", text: $session.patch.replacement, axis: .vertical)
                .font(DesignTokens.Typography.monospacedSmall)
        }
    }
}

#Preview {
    let environment = AppEnvironment.preview
    let viewModel = environment.makeNXNativeViewModel {}
    if let entry = viewModel.knowledgeBase.first {
        TroubleshootingView(viewModel: environment.makeTroubleshootingViewModel(for: entry, onRebuild: {}))
    }
}
