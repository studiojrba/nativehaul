import Foundation
import Observation

/// Drives onboarding (spec §3.6, §4.4, 0.1.1 order in ADR 0059): a friendly conversation, one question at a time, each
/// answer doing the real thing — adding and scanning the games folder, keeping or moving the install location, placing
/// the user's library key, setting up the emulators the user ticks, and saving the mode nativehaul opens in. Music and
/// the interface sounds play from the first screen. "Skip the tour" finishes at once and the defaults fill the rest;
/// finishing (or skipping) marks onboarding done.
@MainActor
@Observable
final class OnboardingChatViewModel {
    /// The scan's typing dots show at least this long, so a fast scan still reads naturally (note 7).
    static let minimumScanWait: Double = 0.6

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
    /// The action under the pointer or with keyboard/controller focus (the scene previews its effect).
    var hoveredActionID: String? {
        didSet {
            if hoveredActionID != nil, hoveredActionID != oldValue {
                playSound(.navigate)
            }
        }
    }

    /// The emulators ticked in the player scene.
    private(set) var selectedOfferIDs: Set<String> = []
    /// The installs started from the player beat, one per ticked emulator.
    private(set) var installs: [ComponentInstallViewModel] = []
    /// Counts answers, so the chat can resume following the newest bubble.
    private(set) var answerCount = 0
    /// Whether the tour is over.
    private(set) var isFinished = false
    /// Reveal everything at once (Reduce Motion).
    var revealsInstantly = false

    @ObservationIgnored private let setup: any OnboardingSetupPerforming
    @ObservationIgnored private let panel: any FilePanelPresenting
    @ObservationIgnored private let sleep: ChatTypist.Sleep
    @ObservationIgnored private let playSound: @MainActor (UISound) -> Void
    @ObservationIgnored private let onFinish: @MainActor () -> Void
    @ObservationIgnored private var hasStarted = false

    /// Creates the conversation. `onFinish` returns to the shell.
    init(
        setup: any OnboardingSetupPerforming,
        panel: any FilePanelPresenting = MockFilePanel(),
        sleep: @escaping ChatTypist.Sleep = ChatTypist.realSleep,
        playSound: @escaping @MainActor (UISound) -> Void = { _ in },
        onFinish: @escaping @MainActor () -> Void = {}
    ) {
        self.setup = setup
        self.panel = panel
        self.sleep = sleep
        self.playSound = playSound
        self.onFinish = onFinish
        typist = ChatTypist(sleep: sleep)
    }

    /// Reads the real state and starts typing the welcome.
    func start() async {
        guard !hasStarted else { return }
        hasStarted = true
        facts = await setup.loadFacts()
        selectedOfferIDs = Set(facts.emulatorOffers.filter(\.isRecommended).map(\.id))
        await present(.welcome)
    }

    /// The hovered action, if it belongs to this beat.
    var hoveredAction: OnboardingAction? {
        actions.first { $0.id == hoveredActionID }
    }

    /// Answers with `action`.
    func choose(_ action: OnboardingAction) async {
        guard isReady, !isFinished else { return }
        playSound(.confirm)
        switch action.effect {
        case .pickFolder:
            let url = await panel.chooseFolder()
            await pickedFolder(url)
        case .pickKeys:
            let url = await panel.chooseFile(allowedExtensions: setup.keysExtensions)
            await pickedKeys(url)
        default:
            answer(action.replyText)
            await perform(action.effect)
        }
    }

    /// A file dropped on the library key scene counts as picking it.
    func dropped(_ url: URL) async {
        guard beat == .keys || beat == .keysHelp, facts.detectedKeys == nil, isReady else { return }
        await pickedKeys(url)
    }

    /// Ticks or unticks an emulator on offer.
    func toggleOffer(_ id: String) {
        guard beat == .player else { return }
        playSound(.navigate)
        if selectedOfferIDs.contains(id) {
            selectedOfferIDs.remove(id)
        } else {
            selectedOfferIDs.insert(id)
        }
    }

    /// "Skip the tour": finish now; the defaults fill the rest.
    func skipTour() {
        playSound(.back)
        finish()
    }

    private func pickedFolder(_ url: URL?) async {
        guard let url, isReady, !isFinished else { return }
        let path = url.path(percentEncoded: false)
        answer("This one: \(OnboardingScript.abbreviate(path))")
        await perform(.useFolder(path))
    }

    private func pickedKeys(_ url: URL?) async {
        guard let url, isReady, !isFinished else { return }
        answer("Here it is.")
        await perform(.placeKeys(url.path(percentEncoded: false)))
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
            await scan(label: OnboardingScript.abbreviate(path)) { await self.setup.addFolderAndScan(path) }
        case .keepFolders:
            await scan(label: OnboardingScript.folderList(facts.configuredFolders)) {
                await self.setup.scanConfiguredFolders()
            }
        case .keepInstallLocation:
            await present(.buildLaunch)
        case let .useExternal(volume):
            setup.setInstallLocation(volume.installFolder)
            facts.installLocation = volume.installFolder
            facts.usesExternal = true
            await present(.buildLaunch)
        case .placeKeys, .showKeysHelp, .skipKeys:
            await performKeys(effect)
        case .installEmulators:
            await installSelected()
        case let .chooseMode(mode):
            facts.chosenMode = mode
            setup.setDefaultMode(mode)
            await present(.closing)
        case .finish:
            await sleep(TypingTiming.finishPause)
            finish()
        case .pickFolder, .pickKeys:
            break
        }
    }

    private func performKeys(_ effect: OnboardingEffect) async {
        switch effect {
        case let .placeKeys(path):
            facts.keysOutcome = setup.provideKeys(at: path)
            await present(.player)
        case .showKeysHelp:
            await present(.keysHelp)
        default:
            facts.keysOutcome = .skipped
            await present(.player)
        }
    }

    /// Says the scan is starting, holds the typing dots for at least ``minimumScanWait`` while it runs, then reports.
    private func scan(label: String, _ run: @MainActor () async -> OnboardingScan) async {
        facts.scannedFolderLabel = label
        facts.scan = nil
        beat = .found
        isScanning = true
        _ = await typist.type([OnboardingScript.scanning], instantly: revealsInstantly)
        typist.beginWaiting(OnboardingScript.scanningPlaceholder)
        let clock = ContinuousClock()
        let started = clock.now
        let result = await run()
        let waited = started.duration(to: clock.now) / .seconds(1)
        if waited < Self.minimumScanWait, !revealsInstantly {
            await sleep(Self.minimumScanWait - waited)
        }
        typist.endWaiting()
        facts.scan = result
        isScanning = false
        await present(.found)
    }

    private func installSelected() async {
        let chosen = facts.emulatorOffers.filter { selectedOfferIDs.contains($0.id) }
        guard !chosen.isEmpty else {
            await present(.final)
            return
        }
        installs = chosen.map { ComponentInstallViewModel(entry: $0.entry, updater: setup.components) }
        installs.forEach { $0.start() }
        await present(.playerInstall)
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
