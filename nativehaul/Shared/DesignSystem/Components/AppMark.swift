import SwiftUI

// The mark's geometry is the icon master's 40-unit drawing (the design's `AppMark` SVG), so the magic-number rule is
// off here.
// swiftlint:disable no_magic_numbers

/// The n. mark drawn as a component (spec §3.6, §7 item 8), matching the app icon: a cream tile with a soft top light,
/// a charcoal "n" arch and an ember dot, corner radius 28% of the side. Constant in both appearances.
struct AppMark: View {
    private enum Drawing {
        static let viewBox: CGFloat = 40
        static let glyphShare: CGFloat = 0.58
        static let tileRadiusShare: CGFloat = 0.28
        static let lightInsetShare: CGFloat = 0.07
        static let lightRadiusShare: CGFloat = 0.24
        static let lightOpacity: Double = 0.70
        static let stroke: CGFloat = 5
        static let archLeft: CGFloat = 9
        static let archRight: CGFloat = 21
        static let archBottom: CGFloat = 31
        static let archShoulder: CGFloat = 15
        static let archTop: CGFloat = 9
        static let dotCenter = CGPoint(x: 29.5, y: 27.5)
        static let dotRadius: CGFloat = 4.5
    }

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            ZStack {
                RoundedRectangle(cornerRadius: side * Drawing.tileRadiusShare, style: .continuous)
                    .fill(Palette.lamp.color)
                RoundedRectangle(cornerRadius: side * Drawing.lightRadiusShare, style: .continuous)
                    .fill(LinearGradient(
                        colors: [Palette.white.opacity(Drawing.lightOpacity).color, Palette.white.opacity(0).color],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .padding(side * Drawing.lightInsetShare)
                glyph.frame(width: side * Drawing.glyphShare, height: side * Drawing.glyphShare)
            }
            .frame(width: side, height: side)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }

    private var glyph: some View {
        Canvas { context, size in
            let scale = min(size.width, size.height) / Drawing.viewBox
            context.scaleBy(x: scale, y: scale)
            var arch = Path()
            arch.move(to: CGPoint(x: Drawing.archLeft, y: Drawing.archBottom))
            arch.addLine(to: CGPoint(x: Drawing.archLeft, y: Drawing.archShoulder))
            arch.addCurve(
                to: CGPoint(x: (Drawing.archLeft + Drawing.archRight) / 2, y: Drawing.archTop),
                control1: CGPoint(x: Drawing.archLeft, y: 11.5),
                control2: CGPoint(x: 11.6, y: Drawing.archTop)
            )
            arch.addCurve(
                to: CGPoint(x: Drawing.archRight, y: Drawing.archShoulder),
                control1: CGPoint(x: 18.4, y: Drawing.archTop),
                control2: CGPoint(x: Drawing.archRight, y: 11.5)
            )
            arch.addLine(to: CGPoint(x: Drawing.archRight, y: Drawing.archBottom))
            context.stroke(
                arch,
                with: .color(Palette.charcoal.color),
                style: StrokeStyle(lineWidth: Drawing.stroke, lineCap: .round, lineJoin: .round)
            )
            let dot = CGRect(
                x: Drawing.dotCenter.x - Drawing.dotRadius,
                y: Drawing.dotCenter.y - Drawing.dotRadius,
                width: Drawing.dotRadius * 2,
                height: Drawing.dotRadius * 2
            )
            context.fill(Path(ellipseIn: dot), with: .color(Palette.ember.color))
        }
    }
}

#Preview {
    AppearancePreviewPair {
        HStack(spacing: DesignTokens.Spacing.xl) {
            AppMark().frame(width: 36, height: 36)
            AppMark().frame(width: 144, height: 144).elevation(.large)
        }
        .padding(DesignTokens.Spacing.xxl)
    }
}

// swiftlint:enable no_magic_numbers
