import CoreHaptics
import Foundation
import GameController

/// Live ``CouchInputProviding`` on Apple's GameController framework (ADR 0052, ADR 0058): Switch Pro, DualSense, Xbox
/// and other extended gamepads, over Bluetooth or USB. The D-pad and left stick move (a held direction repeats after
/// 280ms, then every 110ms; the stick counts past 0.6), face buttons act by position (``ControllerMapping``),
/// shoulders switch the hero game, triggers jump by letter, − (View) leaves couch, + (Menu) opens couch Settings and
/// Home is nativehaul's own while couch shows (its system gesture is turned off).
///
/// GameController delivers input only while nativehaul is frontmost. Rumble uses GameController haptics where the
/// controller offers them (a Switch Pro Controller's HD Rumble is not exposed by Apple's framework, so it is silent).
/// Behaviour on real controllers is to verify on hardware.
@MainActor
final class GameControllerInputSource: CouchInputProviding {
    var onInput: (@MainActor (CouchInput) -> Void)?
    var onControllerChange: (@MainActor (ControllerFamily?) -> Void)?
    private(set) var connectedFamily: ControllerFamily?
    private var observers: [NSObjectProtocol] = []
    private var heldDirection: CouchDirection?
    private var repeatTask: Task<Void, Never>?
    private var haptics: CHHapticEngine?

    /// Creates the source.
    init() {}

    func start() {
        guard observers.isEmpty else { return }
        let center = NotificationCenter.default
        let names: [Notification.Name] = [
            .GCControllerDidBecomeCurrent,
            .GCControllerDidDisconnect,
            .GCControllerDidConnect,
        ]
        observers = names.map { name in
            center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated { self?.bindCurrent() }
            }
        }
        bindCurrent()
    }

    func stop() {
        observers.forEach(NotificationCenter.default.removeObserver)
        observers = []
        repeatTask?.cancel()
        heldDirection = nil
        haptics?.stop()
        haptics = nil
    }

    func rumble(_ strength: RumbleStrength) {
        guard let engine = haptics else { return }
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [CHHapticEventParameter(parameterID: .hapticIntensity, value: strength.intensity)],
            relativeTime: 0
        )
        do {
            let player = try engine.makePlayer(with: CHHapticPattern(events: [event], parameters: []))
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            // A controller that refuses a buzz just doesn't buzz.
        }
    }

    private func bindCurrent() {
        guard let controller = GCController.current ?? GCController.controllers().first,
              let pad = controller.extendedGamepad
        else {
            setFamily(nil)
            haptics = nil
            return
        }
        setFamily(ControllerFamily(productCategory: controller.productCategory))
        haptics = Self.makeHaptics(for: controller)
        pad.dpad.valueChangedHandler = { [weak self] _, xValue, yValue in
            MainActor.assumeIsolated { self?.direction(x: xValue, y: yValue) }
        }
        pad.leftThumbstick.valueChangedHandler = { [weak self] _, xValue, yValue in
            MainActor.assumeIsolated { self?.direction(x: xValue, y: yValue) }
        }
        bind(pad.buttonA, to: ControllerMapping.input(for: .south))
        bind(pad.buttonB, to: ControllerMapping.input(for: .east))
        bind(pad.buttonX, to: ControllerMapping.input(for: .west))
        bind(pad.buttonY, to: ControllerMapping.input(for: .north))
        bind(pad.leftShoulder, to: .previousGame)
        bind(pad.rightShoulder, to: .nextGame)
        bind(pad.leftTrigger, to: .previousLetter)
        bind(pad.rightTrigger, to: .nextLetter)
        bind(pad.buttonMenu, to: .menu)
        if let options = pad.buttonOptions {
            bind(options, to: .view)
        }
        if let home = pad.buttonHome {
            home.preferredSystemGestureState = .disabled
            bind(home, to: .home)
        }
    }

    private func bind(_ button: GCControllerButtonInput, to input: CouchInput?) {
        guard let input else {
            button.pressedChangedHandler = nil
            return
        }
        button.pressedChangedHandler = { [weak self] _, _, isPressed in
            guard isPressed else { return }
            MainActor.assumeIsolated { self?.onInput?(input) }
        }
    }

    private func setFamily(_ family: ControllerFamily?) {
        guard family != connectedFamily else { return }
        connectedFamily = family
        onControllerChange?(family)
    }

    private func direction(x xValue: Float, y yValue: Float) {
        let direction = StickDirection.direction(x: xValue, y: yValue)
        guard direction != heldDirection else { return }
        heldDirection = direction
        repeatTask?.cancel()
        guard let direction else { return }
        onInput?(.move(direction))
        repeatTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(CouchInputTiming.repeatDelay))
            while !Task.isCancelled {
                self?.onInput?(.move(direction))
                try? await Task.sleep(for: .seconds(CouchInputTiming.repeatInterval))
            }
        }
    }

    private static func makeHaptics(for controller: GCController) -> CHHapticEngine? {
        guard let engine = controller.haptics?.createEngine(withLocality: .default) else { return nil }
        do {
            try engine.start()
            return engine
        } catch {
            return nil
        }
    }
}
