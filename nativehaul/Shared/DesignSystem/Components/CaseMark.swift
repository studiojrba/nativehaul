import SwiftUI

// The mark's geometry is its 20-unit drawing (the design's `CaseMark` SVG), so the magic-number rule is off here.
// swiftlint:disable no_magic_numbers

/// The generic mark printed on a game case (spec §3.3, the design's `CaseMark`): two rounded pills side by side, one
/// outlined and one filled, each with a dot. It is nativehaul's own drawing — never a console maker's logo.
struct CaseMark: View {
    /// The ink (the label colour on the case frame).
    let color: Color
    /// The colour the filled pill's dot is punched in (the case frame behind it).
    let punch: Color

    private enum Drawing {
        static let size: CGFloat = 20
        static let stroke: CGFloat = 2
        static let leftPill = CGRect(x: 1.5, y: 1.5, width: 7.5, height: 17)
        static let rightPill = CGRect(x: 11, y: 1.5, width: 7.5, height: 17)
        static let pillRadius: CGFloat = 3.75
        static let leftDot = CGPoint(x: 5.25, y: 6.5)
        static let rightDot = CGPoint(x: 14.75, y: 13)
        static let dotRadius: CGFloat = 1.5
    }

    var body: some View {
        Canvas { context, size in
            let scale = min(size.width, size.height) / Drawing.size
            let origin = CGPoint(
                x: (size.width - Drawing.size * scale) / 2,
                y: (size.height - Drawing.size * scale) / 2
            )
            let place: (CGRect) -> CGRect = { rect in
                CGRect(
                    x: origin.x + rect.minX * scale,
                    y: origin.y + rect.minY * scale,
                    width: rect.width * scale,
                    height: rect.height * scale
                )
            }
            let dot: (CGPoint) -> Path = { center in
                let radius = Drawing.dotRadius * scale
                return Path(ellipseIn: CGRect(
                    x: origin.x + center.x * scale - radius,
                    y: origin.y + center.y * scale - radius,
                    width: radius * 2,
                    height: radius * 2
                ))
            }
            let corner = Drawing.pillRadius * scale
            let left = Path(roundedRect: place(Drawing.leftPill), cornerRadius: corner)
            let right = Path(roundedRect: place(Drawing.rightPill), cornerRadius: corner)
            let stroke = StrokeStyle(lineWidth: Drawing.stroke * scale)
            context.stroke(left, with: .color(color), style: stroke)
            context.fill(right, with: .color(color))
            context.stroke(right, with: .color(color), style: stroke)
            context.fill(dot(Drawing.leftDot), with: .color(color))
            context.fill(dot(Drawing.rightDot), with: .color(punch))
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }
}

#Preview {
    HStack(spacing: DesignTokens.Spacing.lg) {
        CaseMark(color: CaseColors.red.label.color, punch: CaseColors.red.front.color)
            .frame(width: DesignTokens.Spacing.xxl, height: DesignTokens.Spacing.xxl)
            .padding(DesignTokens.Spacing.md)
            .background(CaseColors.red.front.color)
        CaseMark(color: CaseColors.charcoal.label.color, punch: CaseColors.charcoal.front.color)
            .frame(width: DesignTokens.Spacing.xxl, height: DesignTokens.Spacing.xxl)
            .padding(DesignTokens.Spacing.md)
            .background(CaseColors.charcoal.front.color)
    }
    .padding(DesignTokens.Spacing.xl)
}

// swiftlint:enable no_magic_numbers
