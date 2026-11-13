import AppKit
import SwiftUI

/// ← / → handlers for the window while the view is on screen (spec §3.1: the hero switches slides), ignored while
/// typing in a field, with a modifier held, or with a sheet up.
struct ArrowKeyMonitor: ViewModifier {
    /// Called for ←.
    let left: @MainActor () -> Void
    /// Called for →.
    let right: @MainActor () -> Void

    @State private var monitor: Any?

    private static let leftArrow: UInt16 = 123
    private static let rightArrow: UInt16 = 124

    func body(content: Content) -> some View {
        content
            .onAppear {
                guard monitor == nil else { return }
                monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    let isHandled = MainActor.assumeIsolated { handle(event) }
                    return isHandled ? nil : event
                }
            }
            .onDisappear {
                if let monitor {
                    NSEvent.removeMonitor(monitor)
                }
                monitor = nil
            }
    }

    @MainActor
    private func handle(_ event: NSEvent) -> Bool {
        let modifiers = event.modifierFlags.intersection([.command, .option, .control, .shift])
        guard modifiers.isEmpty, let window = event.window, !window.isSheet, window.attachedSheet == nil,
              !(window.firstResponder is NSText)
        else { return false }
        switch event.keyCode {
        case Self.leftArrow:
            left()
            return true
        case Self.rightArrow:
            right()
            return true
        default:
            return false
        }
    }
}

extension View {
    /// Handles ← / → anywhere in the window while this view is shown (not while typing).
    func onArrowKeys(left: @escaping @MainActor () -> Void, right: @escaping @MainActor () -> Void) -> some View {
        modifier(ArrowKeyMonitor(left: left, right: right))
    }
}
