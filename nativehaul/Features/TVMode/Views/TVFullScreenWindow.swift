import AppKit
import SwiftUI

/// Puts the hosting window into full screen while TV mode shows, and restores it afterwards (ADR 0052). macOS hides
/// the menu bar and Dock in a full-screen space. If the window was already full screen, it is left that way.
struct TVFullScreenWindow: NSViewRepresentable {
    /// Remembers how the window was before TV mode.
    final class Coordinator {
        weak var window: NSWindow?
        var wasFullScreen = false
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        let coordinator = context.coordinator
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            coordinator.window = window
            coordinator.wasFullScreen = window.styleMask.contains(.fullScreen)
            window.collectionBehavior.insert(.fullScreenPrimary)
            if !coordinator.wasFullScreen {
                window.toggleFullScreen(nil)
            }
        }
        return view
    }

    func updateNSView(_: NSView, context _: Context) {}

    static func dismantleNSView(_: NSView, coordinator: Coordinator) {
        guard let window = coordinator.window, !coordinator.wasFullScreen,
              window.styleMask.contains(.fullScreen)
        else { return }
        window.toggleFullScreen(nil)
    }
}
