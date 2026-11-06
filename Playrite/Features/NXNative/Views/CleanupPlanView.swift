import SwiftUI

/// Preview of post-build cleanup with explicit approval. Leftovers go to the Trash; the Trash is never emptied.
struct CleanupPlanView: View {
    /// Plan to preview.
    let plan: CleanupPlan
    /// Approve and run.
    let onApprove: () -> Void
    /// Leave everything in place.
    let onSkip: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            SectionHeader(title: "Cleanup Preview", caption: "nothing is deleted · Trash is never emptied")
            ForEach(Array(plan.actions.enumerated()), id: \.offset) { _, action in
                Label(action.summary, systemImage: symbol(for: action))
                    .font(DesignTokens.Typography.monospacedSmall)
            }
            HStack(spacing: DesignTokens.Spacing.md) {
                Button("Apply Cleanup", action: onApprove).keyboardShortcut(.defaultAction)
                Button("Skip", action: onSkip)
            }
        }
    }

    private func symbol(for action: CleanupAction) -> String {
        switch action {
        case .moveApp: "app.badge.checkmark"
        case .moveLibrary: "folder.badge.gearshape"
        case .moveToTrash: "trash"
        case .leave: "hand.raised"
        }
    }
}

#Preview {
    CleanupPlanView(plan: CleanupPlan(actions: [
        .moveApp(from: "/w/out.app", to: "/Users/demo/Switch/Games/Tideborn.app"),
        .moveToTrash("/w/tmp"),
    ]), onApprove: {}, onSkip: {})
        .padding(DesignTokens.Spacing.lg)
}
