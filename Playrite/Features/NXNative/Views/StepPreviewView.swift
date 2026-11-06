import SwiftUI

/// Renders a ``StepPreview``: summary, diff lines and any blocking reason.
struct StepPreviewView: View {
    /// Preview to show.
    let preview: StepPreview

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(preview.summary).font(DesignTokens.Typography.caption)
            ForEach(Array(preview.diffLines.enumerated()), id: \.offset) { _, line in
                Text(line)
                    .font(DesignTokens.Typography.monospacedSmall)
                    .foregroundStyle(line.hasPrefix("+") ? Theme.success : Theme.danger)
            }
            if let blocked = preview.blockedReason {
                Label(blocked, systemImage: "lock").font(DesignTokens.Typography.caption).foregroundStyle(Theme.warning)
            }
        }
    }
}

#Preview {
    StepPreviewView(preview: StepPreview(
        summary: "Patch engine.sh (1 match)",
        diffLines: ["- old", "+ new"],
        blockedReason: nil
    ))
    .padding(DesignTokens.Spacing.lg)
}
