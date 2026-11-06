import SwiftUI

/// Preflight checks and staged-file inventory.
struct PreflightReportView: View {
    /// Report to show.
    let report: PreflightReport

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            SectionHeader(title: "Preflight", caption: report.canBuild ? "ready to build" : "blocked")
            ForEach(report.checks) { check in
                HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.sm) {
                    Image(systemName: check.outcome.symbolName).foregroundStyle(check.outcome.tint)
                    Text(check.kind.displayName).font(DesignTokens.Typography.headline)
                    Text(check.message).foregroundStyle(Theme.secondaryText)
                }
            }
            DisclosureGroup("Staged files (\(report.inventory.count))") {
                ForEach(report.inventory) { file in
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        Image(systemName: file.kind == .titleFile ? "shippingbox" : "doc")
                        Text(file.name)
                        Spacer(minLength: DesignTokens.Spacing.none)
                        Text(ByteCountFormatter.string(fromByteCount: file.size, countStyle: .file))
                            .foregroundStyle(Theme.secondaryText)
                    }
                }
            }
        }
    }
}

#Preview {
    PreflightReportView(report: PreflightReport(checks: [
        PreflightCheck(kind: .engine, outcome: .passed, message: "/Users/demo/tools/nxnative"),
        PreflightCheck(
            kind: .architecture,
            outcome: .failed,
            message: "32-bit titles are not supported and are refused."
        ),
    ], inventory: []))
        .padding(DesignTokens.Spacing.lg)
}
