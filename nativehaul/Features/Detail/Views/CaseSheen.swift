import SwiftUI

/// The light that slides across a face as the case turns (spec §3.3): a white band peaking at 28% alpha, its angle
/// `105° + facing × 0.3`, blended as screen.
struct CaseSheen: View {
    /// The face's facing angle (yaw, plus 180 for the back).
    let facing: Double

    private typealias Metrics = ShellLayout.GameCase
    private static let degreesPerHalfTurn: Double = 180
    private static let middle: Double = 0.5

    var body: some View {
        let (start, end) = Self.points(cssAngle: CaseSpin.sheenAngle(facing: facing))
        LinearGradient(
            stops: [
                .init(color: Palette.white.opacity(0).color, location: Metrics.sheenStart),
                .init(color: Palette.white.opacity(Metrics.sheenPeak).color, location: Metrics.sheenMiddle),
                .init(color: Palette.white.opacity(0).color, location: Metrics.sheenEnd),
            ],
            startPoint: start,
            endPoint: end
        )
        .blendMode(.screen)
        .clipShape(RoundedRectangle(cornerRadius: Metrics.outerRadius, style: .continuous))
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    /// A CSS gradient angle (0° points up, clockwise) as unit start and end points.
    private static func points(cssAngle: Double) -> (UnitPoint, UnitPoint) {
        let radians = cssAngle * .pi / degreesPerHalfTurn
        let dx = sin(radians) * middle
        let dy = -cos(radians) * middle
        return (
            UnitPoint(x: middle - dx, y: middle - dy),
            UnitPoint(x: middle + dx, y: middle + dy)
        )
    }
}

#Preview {
    CaseColors.red.front.color
        .overlay(CaseSheen(facing: CaseSpin.restYaw))
        .frame(width: ShellLayout.GameCase.width, height: ShellLayout.GameCase.height)
}
