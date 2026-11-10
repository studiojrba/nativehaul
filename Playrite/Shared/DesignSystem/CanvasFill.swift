import SwiftUI

/// The canvas behind a page (ADR 0040). Inside the shell it is clear, so the shell's scene tint shows through; in a
/// sheet or the Settings window it is the cream canvas.
struct CanvasFill: ViewModifier {
    @Environment(\.isInsideShell) private var isInsideShell

    func body(content: Content) -> some View {
        content.background(isInsideShell ? Color.clear : Theme.canvas)
    }
}

extension EnvironmentValues {
    /// Whether a view is a page inside ``RailShell`` (which paints the canvas and scene tint itself).
    @Entry var isInsideShell = false
}
