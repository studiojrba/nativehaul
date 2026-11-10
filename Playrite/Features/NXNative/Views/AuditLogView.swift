import SwiftUI

/// Read-only list of audit entries.
struct AuditLogView: View {
    /// Entries, newest first.
    let entries: [AuditEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            SectionHeader(title: "Audit Log", caption: "\(entries.count) entries")
            ForEach(entries) { entry in
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        Text(entry.timestamp, format: .dateTime.hour().minute().second())
                        Text(entry.action).font(DesignTokens.Typography.captionEmphasis)
                    }
                    Text(entry.details).font(DesignTokens.Typography.figuresSmall)
                        .foregroundStyle(Theme.secondaryText)
                }
            }
        }
    }
}

#Preview {
    AuditLogView(entries: [AuditEntry(action: "backupScript", target: "/tools/engine.sh", details: "sha256=abc")])
        .padding(DesignTokens.Spacing.lg)
}
