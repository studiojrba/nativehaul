import AppKit

/// The AppKit side of ``WindowChromeView``.
final class WindowChromeHostView: NSView {
    private var observers: [NSObjectProtocol] = []
    private let placement = TrafficLightPlacement()

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        observers.forEach(NotificationCenter.default.removeObserver)
        observers = []
        guard let window else { return }
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.styleMask.insert(.fullSizeContentView)
        let names: [Notification.Name] = [
            NSWindow.didResizeNotification,
            NSWindow.didEndLiveResizeNotification,
            NSWindow.didExitFullScreenNotification,
            NSWindow.didBecomeKeyNotification,
            NSWindow.didResignKeyNotification,
        ]
        observers = names.map { name in
            NotificationCenter.default.addObserver(forName: name, object: window, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated { self?.placeButtons() }
            }
        }
        placeButtons()
    }

    /// Moves the close, minimise and zoom buttons into the pill.
    func placeButtons() {
        guard let window, !window.styleMask.contains(.fullScreen),
              let close = window.standardWindowButton(.closeButton),
              let titlebar = close.superview,
              let container = titlebar.superview
        else { return }
        let buttons: [NSWindow.ButtonType] = [.closeButton, .miniaturizeButton, .zoomButton]
        var frame = container.frame
        frame.size.height = placement.containerHeight
        frame.origin.y = window.frame.height - placement.containerHeight
        container.frame = frame
        for (type, originX) in zip(buttons, placement.buttonOrigins) {
            guard let button = window.standardWindowButton(type) else { continue }
            button.setFrameOrigin(NSPoint(x: originX, y: placement.buttonY(buttonHeight: button.frame.height)))
        }
    }
}
