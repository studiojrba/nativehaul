import SwiftUI

/// Detail for one job: preflight, log, cleanup preview and troubleshooting suggestions.
struct BuildJobDetailView: View {
    /// The job.
    let job: BuildJob
    /// Queue state.
    let viewModel: NXNativeViewModel
    /// Opens a troubleshooting case for this job.
    let onTroubleshoot: (TroubleshootingCase) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xl) {
                HStack(spacing: DesignTokens.Spacing.md) {
                    Text(job.title.name).font(DesignTokens.Typography.largeTitle)
                    TagLabel(text: job.status.displayName, tint: job.status.tint)
                    Spacer(minLength: DesignTokens.Spacing.none)
                    Button("Re-run Preflight") { viewModel.runPreflight(job.id) }
                    if job.status.isFinished {
                        Button("Re-queue") { viewModel.requeue(job.id) }
                    }
                }
                if let reason = job.failureReason {
                    Text(reason).foregroundStyle(Theme.danger)
                }
                if let report = job.preflight {
                    PreflightReportView(report: report)
                }
                if viewModel.needsKeys(job) {
                    ProvideFilePrompt(request: viewModel.configuration.keysRequest) {
                        viewModel.provideKeys(at: $0, for: job.id)
                    }
                }
                if let message = viewModel.providedFileMessage {
                    Text(message).foregroundStyle(Theme.secondaryText)
                }
                if let plan = job.cleanupPlan {
                    CleanupPlanView(
                        plan: plan,
                        onApprove: { viewModel.approveCleanup(job.id) },
                        onSkip: { viewModel.skipCleanup(job.id) }
                    )
                }
                suggestions
                BuildLogConsole(lines: job.log)
            }
            .padding(DesignTokens.Spacing.xl)
        }
    }

    @ViewBuilder private var suggestions: some View {
        let cases = viewModel.suggestedCases(for: job)
        if !cases.isEmpty {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                SectionHeader(title: "Known Issue Detected")
                ForEach(cases) { entry in
                    Button(entry.title, systemImage: "wrench.and.screwdriver") { onTroubleshoot(entry) }
                }
            }
        }
    }
}

#Preview {
    let environment = AppEnvironment.preview
    BuildJobDetailView(
        job: BuildJob(
            sourcePath: "/s/a.nsp",
            title: TitleInfo(titleID: "0500000000010000", name: "Tideborn", architecture: .bit64)
        ),
        viewModel: environment.makeNXNativeViewModel {},
        onTroubleshoot: { _ in }
    )
}
