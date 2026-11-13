import CoreGraphics

/// Where the real window buttons go so they sit inside the top bar's left pill (spec §3.0; the design's decorative dots
/// are replaced by the real ones): their left edges and the titlebar container height that centres them on the pill.
struct TrafficLightPlacement: Equatable, Sendable {
    /// Height of the titlebar container (buttons are centred in it).
    let containerHeight: CGFloat
    /// Left edge of each button (close, minimise, zoom).
    let buttonOrigins: [CGFloat]

    /// The placement for the top bar's geometry.
    init() {
        let centre = ShellLayout.TopBar.top + ShellLayout.TopBar.pillHeight / Self.halves
        containerHeight = centre * Self.halves
        let first = ShellLayout.TopBar.side + ShellLayout.Chrome.pillPadding
        buttonOrigins = (0 ..< Self.buttonCount).map { first + CGFloat($0) * ShellLayout.Chrome.trafficLightPitch }
    }

    /// The button's bottom edge inside a container of ``containerHeight`` (AppKit coordinates).
    func buttonY(buttonHeight: CGFloat) -> CGFloat {
        (containerHeight - buttonHeight) / Self.halves
    }

    private static let buttonCount = 3
    private static let halves: CGFloat = 2
}
