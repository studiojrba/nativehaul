import AppKit
import SwiftUI

/// Puts the main window's real buttons inside the top bar's left pill (spec §3.0): the window has a hidden, transparent
/// title bar with full-size content, and the buttons are re-placed whenever AppKit lays the title bar out again
/// (resize, full screen, key changes). If AppKit ever refuses, the buttons stay where macOS puts them and the pill's
/// reserved space is simply empty.
struct WindowChromeView: NSViewRepresentable {
    func makeNSView(context _: Context) -> WindowChromeHostView {
        WindowChromeHostView()
    }

    func updateNSView(_ view: WindowChromeHostView, context _: Context) {
        view.placeButtons()
    }
}
