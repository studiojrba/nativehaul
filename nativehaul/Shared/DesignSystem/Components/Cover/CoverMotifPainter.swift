import SwiftUI

// The motifs are Make's SVG drawings (Art.tsx) in its 300×420 view box, ported 1:1; the coordinates are the art itself,
// so the magic-number rule is off in this file.
// swiftlint:disable no_magic_numbers

/// Paints a ``CoverMotif`` into a context already scaled to the 300×420 cover box.
struct CoverMotifPainter {
    /// The colours.
    let palette: CoverPalette

    private static let black = RGBA(hex: 0x000000)

    /// Paints `motif`.
    func paint(_ motif: CoverMotif, in context: inout GraphicsContext) {
        switch motif {
        case .sun: sun(&context)
        case .waves: waves(&context)
        case .peaks: peaks(&context)
        case .rings: rings(&context)
        case .orbit: orbit(&context)
        case .arches: arches(&context)
        case .bloom: bloom(&context)
        case .stripes: stripes(&context)
        }
    }

    private func fill(_ path: Path, _ color: RGBA, opacity: Double = 1, in context: inout GraphicsContext) {
        context.fill(path, with: .color(color.opacity(color.alpha * opacity).color))
    }

    private func circle(_ x: CGFloat, _ y: CGFloat, _ radius: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2))
    }

    private func sun(_ context: inout GraphicsContext) {
        fill(circle(150, 170, 92), palette.mid, in: &context)
        for index in 0 ..< 5 {
            let step = CGFloat(index)
            fill(
                Path(CGRect(x: 40, y: 196 + step * 14, width: 220, height: 3 + step * 1.6)),
                palette.deep,
                in: &context
            )
        }
        var near = Path()
        near.move(to: CGPoint(x: 0, y: 290))
        near.addQuadCurve(to: CGPoint(x: 150, y: 280), control: CGPoint(x: 80, y: 262))
        near.addQuadCurve(to: CGPoint(x: 300, y: 270), control: CGPoint(x: 220, y: 298))
        near.addLines([CGPoint(x: 300, y: 420), CGPoint(x: 0, y: 420)])
        near.closeSubpath()
        fill(near, palette.deep.mixed(with: Self.black, by: 0.25), in: &context)
        var far = Path()
        far.move(to: CGPoint(x: 0, y: 320))
        far.addQuadCurve(to: CGPoint(x: 170, y: 318), control: CGPoint(x: 90, y: 300))
        far.addQuadCurve(to: CGPoint(x: 300, y: 312), control: CGPoint(x: 250, y: 336))
        far.addLines([CGPoint(x: 300, y: 420), CGPoint(x: 0, y: 420)])
        far.closeSubpath()
        fill(far, palette.deep.mixed(with: Self.black, by: 0.4), in: &context)
    }

    private func waves(_ context: inout GraphicsContext) {
        fill(circle(210, 110, 40), palette.light, opacity: 0.9, in: &context)
        for index in 0 ..< 5 {
            let y = 180 + CGFloat(index) * 36
            var wave = Path()
            wave.move(to: CGPoint(x: 0, y: y))
            wave.addQuadCurve(to: CGPoint(x: 75, y: y), control: CGPoint(x: 37, y: y - 15))
            wave.addQuadCurve(to: CGPoint(x: 150, y: y), control: CGPoint(x: 113, y: y + 15))
            wave.addQuadCurve(to: CGPoint(x: 225, y: y), control: CGPoint(x: 187, y: y - 15))
            wave.addQuadCurve(to: CGPoint(x: 300, y: y), control: CGPoint(x: 263, y: y + 15))
            wave.addLines([CGPoint(x: 300, y: 420), CGPoint(x: 0, y: 420)])
            wave.closeSubpath()
            fill(wave, palette.mid.mixed(with: palette.deep, by: Double(index) * 0.2), opacity: 0.95, in: &context)
        }
    }

    private func peaks(_ context: inout GraphicsContext) {
        fill(circle(90, 110, 30), palette.light, in: &context)
        fill(
            polygon([(-20, 300), (90, 150), (150, 220), (210, 130), (330, 300)]),
            palette.mid.mixed(with: palette.deep, by: 0.1),
            in: &context
        )
        fill(polygon([(90, 150), (110, 177), (95, 172), (80, 180)]), palette.light, in: &context)
        fill(polygon([(210, 130), (232, 160), (214, 154), (196, 164)]), palette.light, in: &context)
        fill(
            polygon([(-20, 340), (60, 250), (140, 320), (230, 230), (330, 340), (330, 420), (-20, 420)]),
            palette.mid.mixed(with: palette.deep, by: 0.55),
            in: &context
        )
        var ground = Path()
        ground.move(to: CGPoint(x: -20, y: 380))
        ground.addQuadCurve(to: CGPoint(x: 330, y: 380), control: CGPoint(x: 150, y: 330))
        ground.addLines([CGPoint(x: 330, y: 420), CGPoint(x: -20, y: 420)])
        ground.closeSubpath()
        fill(ground, palette.deep.mixed(with: Self.black, by: 0.3), in: &context)
    }

    private func rings(_ context: inout GraphicsContext) {
        for (index, radius) in [120.0, 96, 72, 48].enumerated() {
            let color = index.isMultiple(of: 2) ? palette.mid : palette.light
            let opacity = 0.85 - Double(index) * 0.08
            context.stroke(
                circle(150, 180, radius),
                with: .color(color.opacity(opacity).color),
                lineWidth: index == 3 ? 48 : 10
            )
        }
        fill(circle(150, 180, 18), palette.light, in: &context)
    }

    private func orbit(_ context: inout GraphicsContext) {
        let ring = Path(ellipseIn: CGRect(x: 20, y: 136, width: 260, height: 88))
            .applying(rotation(degrees: -18, around: CGPoint(x: 150, y: 180)))
        context.stroke(ring, with: .color(palette.light.opacity(0.6).color), lineWidth: 2)
        fill(circle(150, 180, 70), palette.mid, in: &context)
        fill(circle(128, 160, 22), palette.light, opacity: 0.5, in: &context)
        fill(circle(262, 140, 12), palette.light, in: &context)
        fill(circle(48, 226, 7), palette.light, in: &context)
        for index in 0 ..< 14 {
            let x = CGFloat((index * 71) % 290 + 5)
            let y = CGFloat((index * 47) % 120 + 20)
            fill(circle(x, y, 1.4), palette.light, opacity: 0.8, in: &context)
        }
    }

    private func arches(_ context: inout GraphicsContext) {
        for index in 0 ..< 3 {
            let step = CGFloat(index)
            let radius = 90 - step * 22
            let left = 60 + step * 22
            let top = 190 + step * 22
            var arch = Path()
            arch.move(to: CGPoint(x: left, y: 330))
            arch.addLine(to: CGPoint(x: left, y: top))
            arch.addArc(
                center: CGPoint(x: left + radius, y: top),
                radius: radius,
                startAngle: .degrees(180),
                endAngle: .degrees(360),
                clockwise: false
            )
            arch.addLine(to: CGPoint(x: left + radius * 2, y: 330))
            arch.closeSubpath()
            fill(arch, palette.mid.mixed(with: palette.deep, by: Double(index) * 0.35), in: &context)
        }
        fill(circle(150, 232, 14), palette.light, in: &context)
        fill(
            Path(CGRect(x: 0, y: 330, width: 300, height: 90)),
            palette.deep.mixed(with: Self.black, by: 0.3),
            in: &context
        )
    }

    private func bloom(_ context: inout GraphicsContext) {
        let center = CGPoint(x: 150, y: 180)
        for index in 0 ..< 8 {
            let petal = Path(ellipseIn: CGRect(x: center.x - 34, y: center.y - 54 - 78, width: 68, height: 156))
                .applying(rotation(degrees: Double(index) * 45, around: center))
            fill(petal, index.isMultiple(of: 2) ? palette.mid : palette.light, opacity: 0.9, in: &context)
        }
        fill(circle(150, 180, 30), palette.deep, in: &context)
        fill(circle(150, 180, 16), palette.light, in: &context)
    }

    private func stripes(_ context: inout GraphicsContext) {
        let turn = rotation(degrees: 24, around: CGPoint(x: 150, y: 210))
        for index in 0 ..< 9 {
            let stripe = Path(CGRect(x: -60 + CGFloat(index) * 50, y: -40, width: 22, height: 520)).applying(turn)
            fill(stripe, index.isMultiple(of: 2) ? palette.mid : palette.light, opacity: 0.9, in: &context)
        }
        fill(circle(150, 170, 56), palette.deep, in: &context)
        fill(circle(150, 170, 30), palette.light, in: &context)
    }

    private func polygon(_ points: [(CGFloat, CGFloat)]) -> Path {
        var path = Path()
        path.addLines(points.map { CGPoint(x: $0.0, y: $0.1) })
        path.closeSubpath()
        return path
    }

    private func rotation(degrees: Double, around point: CGPoint) -> CGAffineTransform {
        CGAffineTransform(translationX: point.x, y: point.y)
            .rotated(by: degrees * .pi / 180)
            .translatedBy(x: -point.x, y: -point.y)
    }
}

// swiftlint:enable no_magic_numbers
