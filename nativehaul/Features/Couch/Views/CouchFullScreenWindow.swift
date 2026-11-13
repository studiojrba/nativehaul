import AppKit
import SwiftUI

/// Puts the main window into full screen while couch shows and hands it back afterwards (ADR 0052, ADR 0058): macOS
/// hides the menu bar and Dock in a full-screen space. A window that was already full screen is left that way.
struct CouchFullScreenWindow: NSViewRepresentable {
    /// Remembers how the window was before couch.
    final class Coordinator {
        /// The window couch took.
        weak var window: NSWindow?
        /// Whether it was already full screen.
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
