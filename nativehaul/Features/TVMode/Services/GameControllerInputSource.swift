import Foundation
import GameController

/// Live ``TVInputProviding`` using Apple's GameController framework (ADR 0052): Switch Pro, DualSense, Xbox and other
/// extended gamepads, over Bluetooth or USB. The D-pad and left stick move (held directions repeat), face buttons go
/// through ``ControllerMapping``, shoulders switch shelves, triggers jump by letter, and Menu/+/Options opens the TV
/// menu.
///
/// GameController delivers input only while nativehaul is frontmost, which is all TV mode's library needs. Behaviour
/// on real controllers is to verify on hardware.
@MainActor
final class GameControllerInputSource: TVInputProviding {
    var onInput: (@MainActor (TVInput) -> Void)?
    var onFamilyChange: (@MainActor (ControllerFamily) -> Void)?
    private var observers: [NSObjectProtocol] = []
    private var family: ControllerFamily = .keyboard
    private var heldDirection: TVDirection?
    private var repeatTask: Task<Void, Never>?

    /// Creates the source.
    init() {}

    func start() {
        guard observers.isEmpty else { return }
        let center = NotificationCenter.default
        observers = [
            center.addObserver(forName: .GCControllerDidBecomeCurrent, object: nil, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated { self?.bindCurrent() }
            },
            center.addObserver(forName: .GCControllerDidDisconnect, object: nil, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated { self?.bindCurrent() }
            },
        ]
        bindCurrent()
    }

    func stop() {
        observers.forEach(NotificationCenter.default.removeObserver)
        observers = []
        repeatTask?.cancel()
        heldDirection = nil
    }

    private func bindCurrent() {
        guard let controller = GCController.current ?? GCController.controllers().first,
              let pad = controller.extendedGamepad
        else {
            setFamily(.keyboard)
            return
        }
        setFamily(ControllerFamily(productCategory: controller.productCategory))
        pad.dpad.valueChangedHandler = { [weak self] _, xValue, yValue in
            MainActor.assumeIsolated { self?.direction(x: xValue, y: yValue) }
        }
        pad.leftThumbstick.valueChangedHandler = { [weak self] _, xValue, yValue in
            MainActor.assumeIsolated { self?.direction(x: xValue, y: yValue) }
        }
        bind(pad.buttonA) { [weak self] in self?.face(.south) }
        bind(pad.buttonB) { [weak self] in self?.face(.east) }
        bind(pad.buttonX) { [weak self] in self?.face(.west) }
        bind(pad.buttonY) { [weak self] in self?.face(.north) }
        bind(pad.leftShoulder) { [weak self] in self?.onInput?(.previousShelf) }
        bind(pad.rightShoulder) { [weak self] in self?.onInput?(.nextShelf) }
        bind(pad.leftTrigger) { [weak self] in self?.onInput?(.previousLetter) }
        bind(pad.rightTrigger) { [weak self] in self?.onInput?(.nextLetter) }
        bind(pad.buttonMenu) { [weak self] in self?.onInput?(.menu) }
    }

    private func bind(_ button: GCControllerButtonInput, action: @escaping @MainActor () -> Void) {
        button.pressedChangedHandler = { _, _, isPressed in
            guard isPressed else { return }
            MainActor.assumeIsolated { action() }
        }
    }

    private func setFamily(_ newFamily: ControllerFamily) {
        family = newFamily
        onFamilyChange?(newFamily)
    }

    private func face(_ button: FaceButton) {
        if let input = ControllerMapping.input(for: button, family: family) {
            onInput?(input)
        }
    }

    private func direction(x xValue: Float, y yValue: Float) {
        let threshold = DesignTokens.TVMode.stickThreshold
        let direction: TVDirection? = if abs(xValue) >= abs(yValue) {
            xValue > threshold ? .right : (xValue < -threshold ? .left : nil)
        } else {
            yValue > threshold ? .up : (yValue < -threshold ? .down : nil)
        }
        guard direction != heldDirection else { return }
        heldDirection = direction
        repeatTask?.cancel()
        guard let direction else { return }
        onInput?(.move(direction))
        repeatTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(DesignTokens.TVMode.repeatDelay))
            while !Task.isCancelled {
                self?.onInput?(.move(direction))
                try? await Task.sleep(for: .seconds(DesignTokens.TVMode.repeatInterval))
            }
        }
    }
}
