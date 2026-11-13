import Foundation
import Observation

/// Drives onboarding (spec §3.6, §4.4): a friendly conversation, one question at a time, each answer doing the real
/// thing — adding and scanning the games folder, keeping or moving the install location, placing the user's keys file,
/// and saving the mode nativehaul opens in. "Skip the tour" finishes at once and the defaults fill the rest. It never
/// touches the appearance, so a replay keeps it; finishing (or skipping) marks onboarding done.
@MainActor
@Observable
final class OnboardingChatViewModel {
    /// The current beat.
    private(set) var beat = OnboardingBeat.welcome
    /// The conversation.
    let typist: ChatTypist
    /// The current beat's actions (shown once ``isReady``).
    private(set) var actions: [OnboardingAction] = []
    /// Whether the beat's typing has finished and its actions show.
    private(set) var isReady = false
    /// The real state the conversation talks about.
    private(set) var facts = OnboardingFacts()
    /// Whether a scan is running.
    private(set) var isScanning = false
    /// The action under the pointer (the scene previews its effect).
    var hoveredActionID: String?
    /// The open panel showing, if any.
    var picker: OnboardingPicker?
    /// Counts answers, so the chat can resume following the newest bubble.
    private(set) var answerCount = 0
    /// Whether the tour is over.
    private(set) var isFinished = false
    /// Reveal everything at once (Reduce Motion).
    var revealsInstantly = false

    @ObservationIgnored private let setup: any OnboardingSetupPerforming
    @ObservationIgnored private let sleep: ChatTypist.Sleep
    @ObservationIgnored private let onFinish: @MainActor () -> Void
    @ObservationIgnored private var hasStarted = false
    @ObservationIgnored private var pendingPicker: OnboardingPicker?

    /// Creates the conversation. `onFinish` returns to the shell.
    init(
        setup: any OnboardingSetupPerforming,
        sleep: @escaping ChatTypist.Sleep = ChatTypist.realSleep,
        onFinish: @escaping @MainActor () -> Void = {}
    ) {
        self.setup = setup
        self.sleep = sleep
        self.onFinish = onFinish
        typist = ChatTypist(sleep: sleep)
    }

    /// Reads the real state and starts typing the welcome.
    func start() async {
        guard !hasStarted else { return }
        hasStarted = true
        facts = await setup.loadFacts()
        await present(.welcome)
    }

    /// The hovered action, if it belongs to this beat.
    var hoveredAction: OnboardingAction? {
        actions.first { $0.id == hoveredActionID }
    }

    /// Answers with `action`.
    func choose(_ action: OnboardingAction) async {
        guard isReady, !isFinished else { return }
        switch action.effect {
        case .pickFolder:
            pendingPicker = .folder
            picker = .folder
        case .pickKeys:
            pendingPicker = .keys
            picker = .keys
        default:
            answer(action.replyText)
            await perform(action.effect)
        }
    }

    /// The open panel closed: `url` is the pick, `nil` a cancel (the question stays open).
    func picked(_ url: URL?) async {
        let current = pendingPicker
        pendingPicker = nil
        picker = nil
        guard let url, let current, isReady, !isFinished else { return }
        let path = url.path(percentEncoded: false)
        switch current {
        case .folder:
            answer("This one: \(OnboardingScript.abbreviate(path))")
            await perform(.useFolder(path))
        case .keys:
            answer("Here it is.")
            await perform(.placeKeys(path))
        }
    }

    /// A file dropped on the keys scene counts as picking it.
    func dropped(_ url: URL) async {
        guard beat == .keys || beat == .keysHelp, facts.detectedKeys == nil else { return }
        pendingPicker = .keys
        await picked(url)
    }

    /// "Skip the tour": finish now; the defaults fill the rest.
    func skipTour() {
        finish()
    }

    private func answer(_ text: String) {
        isReady = false
        hoveredActionID = nil
        answerCount += 1
        typist.appendReply(text)
    }

    private func present(_ next: OnboardingBeat) async {
        guard !isFinished else { return }
        beat = next
        isReady = false
        actions = OnboardingScript.actions(for: next, facts: facts)
        let messages = OnboardingScript.messages(for: next, facts: facts)
        if await typist.type(messages, instantly: revealsInstantly), !isFinished {
            isReady = true
        }
    }

    private func perform(_ effect: OnboardingEffect) async {
        switch effect {
        case let .advance(next):
            await present(next)
        case let .useFolder(path):
            await scan(label: OnboardingScript.abbreviate(path)) { await setup.addFolderAndScan(path) }
        case .keepFolders:
            await scan(label: OnboardingScript.folderList(facts.configuredFolders)) {
                await setup.scanConfiguredFolders()
            }
        case .keepInstallLocation:
            await present(.keys)
        case let .useExternal(volume):
            setup.setInstallLocation(volume.installFolder)
            facts.installLocation = volume.installFolder
            facts.usesExternal = true
            await present(.keys)
        case let .placeKeys(path):
            facts.keysOutcome = setup.provideKeys(at: path)
            await present(.player)
        case .showKeysHelp:
            await present(.keysHelp)
        case .skipKeys:
            facts.keysOutcome = .skipped
            await present(.player)
        case let .chooseMode(mode):
            setup.setDefaultMode(mode)
            await sleep(TypingTiming.finishPause)
            finish()
        case .pickFolder, .pickKeys:
            break
        }
    }

    private func scan(label: String, _ run: () async -> OnboardingScan) async {
        facts.scannedFolderLabel = label
        facts.scan = nil
        beat = .found
        isScanning = true
        facts.scan = await run()
        isScanning = false
        await present(.found)
    }

    private func finish() {
        guard !isFinished else { return }
        isFinished = true
        isReady = false
        typist.stop()
        setup.markCompleted()
        onFinish()
    }
}
