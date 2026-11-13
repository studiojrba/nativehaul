import Foundation
import Observation

/// Couch mode's state (spec §3.7, ADR 0058): the desktop's screens at 10-foot scale, driven by the controller. Inputs
/// go through the pure ``CouchNavigator``; this carries out what it asks — sounds and rumble, the shared hero
/// carousel, launches (full screen unless "Open windowed"), toasts, couch Settings, and the Resume/Close overlay with
/// its graceful-then-force close.
@MainActor
@Observable
final class CouchViewModel {
    /// Where focus is.
    var state = CouchFocusState()
    /// The toast on show.
    private(set) var toast: CouchToast?
    /// The connected controller, if any.
    private(set) var controllerFamily: ControllerFamily?
    /// The clock's time.
    private(set) var now: Date
    /// Inputs handled so far (any input restarts the auto-advance cycle).
    private(set) var inputCount = 0
    /// The screen size (couch scales from its height).
    private(set) var size = CGSize.zero
    /// Couch Detail's state, while it shows a game.
    var detail: DetailViewModel?
    /// Palettes read so far, by game (the background wash follows the focused game).
    var palettes: [UUID: GamePalette] = [:]
    /// "Open in" (mirrors the saved choice).
    var defaultMode: AppMode
    /// "Controller rumble" (mirrors the saved choice).
    var isRumbleEnabled: Bool

    /// Home's state (the hero carousel is shared with the desktop).
    let home: HomeViewModel
    /// The shared library.
    let library: LibraryViewModel
    /// Builds' state.
    let builds: BuildsViewModel
    /// Music and interface sounds.
    let audio: AudioController
    /// Light/Dark.
    let appearance: AppearanceController

    @ObservationIgnored let services: CouchServices
    @ObservationIgnored var closeFlow = CloseGameFlow()
    @ObservationIgnored var toastTurn = 0

    /// Creates couch's state over the desktop's view models and the couch services.
    init(
        home: HomeViewModel,
        library: LibraryViewModel,
        builds: BuildsViewModel,
        audio: AudioController,
        appearance: AppearanceController,
        services: CouchServices
    ) {
        self.home = home
        self.library = library
        self.builds = builds
        self.audio = audio
        self.appearance = appearance
        self.services = services
        now = services.clock()
        defaultMode = services.modePreferences.defaultMode
        isRumbleEnabled = services.modePreferences.isRumbleEnabled
    }

    // MARK: Lifecycle

    /// Couch is on screen: listen to controllers, keep the hero still until focus rests on it, and come back in front
    /// after a game.
    func start() {
        services.input.onInput = { [weak self] in self?.handle($0) }
        services.input.onControllerChange = { [weak self] in self?.controllerFamily = $0 }
        services.input.start()
        controllerFamily = services.input.connectedFamily
        services.handoff.restoresInFront = true
        home.carousel.isHovered = false
        defaultMode = services.modePreferences.defaultMode
        isRumbleEnabled = services.modePreferences.isRumbleEnabled
        tick()
    }

    /// Couch has left the screen.
    func stop() {
        services.input.stop()
        services.handoff.restoresInFront = false
    }

    /// The screen size changed.
    func updateSize(_ newSize: CGSize) {
        size = newSize
    }

    /// Refreshes the clock.
    func tick() {
        now = services.clock()
    }

    // MARK: Input

    /// Handles one input from a controller or the development keyboard.
    func handle(_ input: CouchInput) {
        inputCount += 1
        let effects = CouchNavigator.reduce(&state, input, context: context)
        for effect in effects {
            apply(effect)
        }
    }

    /// Shows a toast; it dismisses itself after 1100ms.
    func show(_ newToast: CouchToast) {
        toast = newToast
        toastTurn += 1
        let turn = toastTurn
        Task { [sleep = services.sleep] in
            await sleep(CouchInputTiming.toastDuration)
            if self.toastTurn == turn {
                self.toast = nil
            }
        }
    }

    // MARK: Auto-advance

    /// Whether the hero may advance by itself right now (``CouchAutoAdvance``).
    var isAutoAdvanceEligible: Bool {
        CouchAutoAdvance.isEligible(state, heroCount: home.slides.count)
    }

    /// What couch's auto-advance timer is keyed on: any input, switch or eligibility change restarts it.
    var autoAdvanceKey: CouchAutoAdvanceKey {
        CouchAutoAdvanceKey(turn: home.carousel.turn, inputCount: inputCount, isEligible: isAutoAdvanceEligible)
    }

    /// Waits one cycle and advances the hero, only while focus rests on it.
    func runAutoAdvance() async {
        guard isAutoAdvanceEligible else { return }
        await home.carousel.runAutoAdvance()
    }
}
