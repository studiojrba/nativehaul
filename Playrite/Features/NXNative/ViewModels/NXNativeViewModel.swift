import Foundation
import Observation

/// Build queue for the nxnative module (on by default, ADR 0021): preflight → build (streamed log) → cleanup preview →
/// apply.
@MainActor
@Observable
final class NXNativeViewModel {
    /// All jobs in queue order.
    private(set) var jobs: [BuildJob] = []
    /// Selected job.
    var selectedJobID: UUID?
    /// `true` while the queue is running.
    private(set) var isProcessing = false
    /// Last error not tied to a job.
    private(set) var errorMessage: String?
    /// What the page opens to: ready, engine not found, or switched off by the user.
    private(set) var readiness = NXNativeReadiness.engineNotFound

    @ObservationIgnored let services: NXNativeServices
    @ObservationIgnored private let store: any EngineConfigurationStoring
    @ObservationIgnored private let onAppBuilt: @MainActor (TitleInfo, String) -> Void
    @ObservationIgnored private var processingTask: Task<Void, Never>?

    /// Creates the view model. `onAppBuilt(titleInfo, appPath)` registers finished apps in the library.
    init(
        services: NXNativeServices,
        store: any EngineConfigurationStoring,
        onAppBuilt: @escaping @MainActor (TitleInfo, String) -> Void
    ) {
        self.services = services
        self.store = store
        self.onAppBuilt = onAppBuilt
        refreshReadiness()
    }

    /// Current configuration, with the detected engine and `prod.keys` filled in where Settings has no override.
    var configuration: EngineConfiguration {
        services.locator.resolve(store.load())
    }

    /// Re-detects the engine and keys (e.g. when the page appears, after the user set things up elsewhere).
    func refreshReadiness() {
        readiness = NXNativeReadiness(resolved: configuration, files: services.files)
    }

    /// Turns the module back on after the user switched it off.
    func turnOn() {
        updateStoredConfiguration { $0.isEnabled = true }
    }

    /// Uses the engine the user chose (an override), then re-checks queued jobs.
    func chooseEngine(at path: String) {
        updateStoredConfiguration { $0.enginePath = path }
    }

    /// The selected job.
    var selectedJob: BuildJob? {
        jobs.first { $0.id == selectedJobID }
    }

    /// All documented troubleshooting cases.
    var knowledgeBase: [TroubleshootingCase] {
        services.knowledgeBase.cases()
    }

    /// Cases suggested by a job's log.
    func suggestedCases(for job: BuildJob) -> [TroubleshootingCase] {
        services.knowledgeBase.cases(matching: job.log)
    }

    /// Adds a job and runs its preflight immediately.
    func enqueue(sourcePath: String, title: TitleInfo) {
        let job = BuildJob(sourcePath: sourcePath, title: title)
        jobs.append(job)
        selectedJobID = job.id
        runPreflight(job.id)
    }

    /// Re-runs preflight for a job (read-only).
    func runPreflight(_ id: UUID) {
        update(id) { job in job.preflight = preflightRunner.run(for: job, configuration: configuration) }
    }

    /// Removes a job that is not building.
    func remove(_ id: UUID) {
        guard let job = jobs.first(where: { $0.id == id }), job.status != .building else { return }
        jobs.removeAll { $0.id == id }
    }

    /// Puts a finished job back in the queue (e.g. after a troubleshooting fix).
    func requeue(_ id: UUID) {
        update(id) { job in
            job.status = .queued
            job.failureReason = nil
            job.cleanupPlan = nil
            job.log.append(BuildLogLine(timestamp: .now, stream: .system, text: "— re-queued —"))
        }
    }

    /// Starts processing queued jobs one at a time.
    func startQueue() {
        guard !isProcessing, configuration.isEnabled else { return }
        isProcessing = true
        processingTask = Task { [weak self] in
            await self?.processQueue()
            self?.isProcessing = false
        }
    }

    /// Cancels the running build (terminating the engine) and stops the queue.
    func cancel() {
        processingTask?.cancel()
    }

    /// Waits for the current queue run (used by tests).
    func waitForQueue() async {
        await processingTask?.value
    }

    /// Executes an approved cleanup plan and registers the finished app.
    func approveCleanup(_ id: UUID) {
        guard let job = jobs.first(where: { $0.id == id }), let plan = job.cleanupPlan else { return }
        do {
            try CleanupExecutor(files: services.files, audit: services.audit).execute(plan)
            update(id) { $0.status = .succeeded; $0.cleanupPlan = nil }
            if let appPath = plan.finalAppPath {
                onAppBuilt(job.title, appPath)
            }
        } catch {
            update(id) { $0.failureReason = "Cleanup stopped: \(error.localizedDescription)" }
        }
    }

    /// Leaves the work directory untouched and marks the job done.
    func skipCleanup(_ id: UUID) {
        update(id) { job in
            job.status = .succeeded
            job.cleanupPlan = nil
            job.log.append(BuildLogLine(
                timestamp: .now,
                stream: .system,
                text: "Cleanup skipped; work folder left as-is."
            ))
        }
    }

    /// Result of the last provided file, if any.
    private(set) var providedFileMessage: String?

    /// Whether `job`'s preflight is missing the user's prod.keys.
    func needsKeys(_ job: BuildJob) -> Bool {
        job.preflight?.checks.contains { $0.kind == .keys && $0.outcome == .failed } == true
    }

    /// Copies the user's own prod.keys to where the engine reads it, then re-runs the job's preflight.
    func provideKeys(at path: String, for jobID: UUID) {
        do {
            switch try UserFilePlacer.place(path, for: configuration.keysRequest, files: services.files) {
            case .placed: providedFileMessage = "Thanks — your prod.keys is in place."
            case .alreadyPresent: providedFileMessage = "A prod.keys was already there, so it was kept."
            }
            runPreflight(jobID)
        } catch {
            providedFileMessage = error.localizedDescription
        }
    }

    private func updateStoredConfiguration(_ change: (inout EngineConfiguration) -> Void) {
        var stored = store.load()
        change(&stored)
        store.save(stored)
        refreshReadiness()
        for job in jobs where job.status != .building {
            runPreflight(job.id)
        }
    }

    private var preflightRunner: PreflightRunner {
        PreflightRunner(
            files: services.files,
            disk: services.disk,
            appBundlePath: services.appBundlePath,
            homeDirectory: services.homeDirectory
        )
    }

    private func processQueue() async {
        while !Task.isCancelled, let job = jobs.first(where: { $0.status == .queued }) {
            await process(job.id)
        }
    }

    private func process(_ id: UUID) async {
        update(id) { $0.status = .preflight }
        runPreflight(id)
        guard let job = jobs.first(where: { $0.id == id }), job.preflight?.canBuild == true else {
            update(id) { $0.status = .failed; $0.failureReason = BuildError.preflightFailed.errorDescription }
            return
        }
        let workDirectory = (EngineConfiguration.expand(configuration.workRoot) as NSString)
            .appendingPathComponent(id.uuidString)
        do {
            try services.files.createDirectory(atPath: workDirectory)
            update(id) { $0.status = .building }
            let invocation = EngineInvocationBuilder.invocation(
                for: job,
                configuration: configuration,
                workDirectory: workDirectory,
                files: services.files,
                homeDirectory: services.homeDirectory
            )
            for try await line in services.runner.run(invocation) {
                update(id) { $0.log.append(line) }
            }
            guard !Task.isCancelled else {
                update(id) { $0.status = .cancelled }
                return
            }
            let plan = CleanupPlanner(files: services.files).plan(
                workDirectory: workDirectory, titleName: job.title.name, titleID: job.title.titleID,
                configuration: configuration
            )
            guard plan.finalAppPath != nil else { throw BuildError.noAppProduced }
            update(id) { $0.status = .awaitingCleanup; $0.cleanupPlan = plan }
        } catch {
            update(id) { job in
                job.status = Task.isCancelled ? .cancelled : .failed
                job.failureReason = error.localizedDescription
                job.log.append(BuildLogLine(timestamp: .now, stream: .system, text: error.localizedDescription))
            }
        }
    }

    private func update(_ id: UUID, _ change: (inout BuildJob) -> Void) {
        guard let index = jobs.firstIndex(where: { $0.id == id }) else { return }
        change(&jobs[index])
    }
}
