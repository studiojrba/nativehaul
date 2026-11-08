import SwiftUI

/// One troubleshooting step with live preview, state and Run button.
struct TroubleshootingStepRow: View {
    /// Step.
    let step: TroubleshootingStep
    /// Current state.
    let state: StepState
    /// Preview of what it will do.
    let preview: StepPreview
    /// Runs the step.
    let onRun: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                Text("\(step.id).").font(DesignTokens.Typography.headline)
                Text(step.title).font(DesignTokens.Typography.headline)
                Spacer(minLength: DesignTokens.Spacing.none)
                stateTag
                Button(step.kind.actionTitle, action: onRun).disabled(preview.blockedReason != nil || state.isDone)
            }
            Text(step.detail).font(DesignTokens.Typography.caption).foregroundStyle(Theme.secondaryText)
            StepPreviewView(preview: preview)
        }
        .padding(.vertical, DesignTokens.Spacing.xs)
    }

    @ViewBuilder private var stateTag: some View {
        switch state {
        case .pending: TagLabel(text: "Pending", tint: Theme.secondaryText)
        case let .done(message): TagLabel(text: "Done", symbolName: "checkmark", tint: Theme.success).help(message)
        case let .reverted(message): TagLabel(text: "Reverted", symbolName: "arrow.uturn.backward", tint: Theme.info)
            .help(message)
        case let .failed(message): TagLabel(text: "Failed", symbolName: "xmark", tint: Theme.danger).help(message)
        }
    }
}

#Preview {
    TroubleshootingStepRow(
        step: TroubleshootingStep(
            id: 1,
            kind: .backupScript,
            title: "Back up the engine script",
            detail: "Copies the script."
        ),
        state: .pending,
        preview: StepPreview(summary: "Copy engine.sh to backups.", diffLines: [], blockedReason: nil),
        onRun: {}
    )
    .padding(DesignTokens.Spacing.lg)
}
