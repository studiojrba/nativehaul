import SwiftUI

/// Everything else about the selected build, under the stat cards (ADR 0056: kept from the old dashboard): the failure,
/// "Please provide your prod.keys" when the checks miss it, the tidy-up plan to approve or skip, known issues the log
/// matches, the pre-build checks, the build log, and Re-check / Put back in the queue / Remove.
struct BuildsJobTools: View {
    /// The build queue.
    let queue: NXNativeViewModel
    /// The build.
    let job: BuildJob
    /// Opens a troubleshooting case.
    let troubleshoot: (TroubleshootingCase) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: ShellLayout.Builds.toolsGap) {
            if queue.needsKeys(job) {
                ProvideFilePrompt(request: queue.configuration.keysRequest) { queue.provideKeys(at: $0, for: job.id) }
            }
            if let message = queue.providedFileMessage {
                Text(message).foregroundStyle(Theme.inkSoft)
            }
            if let plan = job.cleanupPlan {
                CleanupPlanView(
                    plan: plan,
                    onApprove: { queue.approveCleanup(job.id) },
                    onSkip: { queue.skipCleanup(job.id) }
                )
            }
            suggestions
            if let report = job.preflight {
                DisclosureGroup("Pre-build checks") { PreflightReportView(report: report) }
            }
            if !job.log.isEmpty {
                DisclosureGroup("Build log") { BuildLogConsole(lines: job.log) }
            }
            actions
        }
        .font(Typeface.sans(TypeStyle.Size.body))
        .foregroundStyle(Theme.ink)
    }

    @ViewBuilder private var suggestions: some View {
        let cases = queue.suggestedCases(for: job)
        if !cases.isEmpty {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Eyebrow("Known issue spotted")
                ForEach(cases) { entry in
                    Button(entry.title, systemImage: "wrench.and.screwdriver") { troubleshoot(entry) }
                        .buttonStyle(SurfacePillButtonStyle(isCompact: true))
                }
            }
        }
    }

    private var actions: some View {
        FlowLayout(spacing: DesignTokens.Spacing.sm) {
            Button("Re-check", systemImage: "checklist") { queue.runPreflight(job.id) }
                .buttonStyle(SurfacePillButtonStyle(isCompact: true))
            if job.status.isFinished {
                Button("Put Back in the Queue", systemImage: "arrow.uturn.backward") { queue.requeue(job.id) }
                    .buttonStyle(SurfacePillButtonStyle(isCompact: true))
            }
            if job.status != .building {
                Button("Remove from the List", systemImage: "xmark") { queue.remove(job.id) }
                    .buttonStyle(SurfacePillButtonStyle(isCompact: true))
            }
        }
    }
}

#Preview {
    let environment = AppEnvironment.preview
    BuildsJobTools(
        queue: environment.makeNXNativeViewModel {},
        job: BuildJob(
            sourcePath: "/s/a.nsp",
            title: TitleInfo(titleID: "0100000000010000", name: "Lantern Coast", architecture: .bit64)
        ),
        troubleshoot: { _ in }
    )
    .padding(DesignTokens.Spacing.xl)
}
