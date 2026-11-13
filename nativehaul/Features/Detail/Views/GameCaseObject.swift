import SwiftUI

/// The game case on Detail (spec §3.3 `BoxCase`): a physical case you can grab and turn over. Drag to spin (yaw
/// 0.45°/pt, pitch −0.2°/pt within ±25°), hover for a little parallax, let go and it settles to the nearest side over
/// 1100ms; the button turns it a half turn. It floats, casts a floor shadow that follows its pose, and shows the grab
/// cursor. Reduce Motion: no float, and turns land directly.
struct GameCaseObject: View {
    /// What is printed on the case.
    let artwork: CaseArtwork
    /// The turn button's muted suffix.
    let turnHint: String
    /// Scale from the reference size (300 × 484) to fit the column.
    var scale: CGFloat = 1

    @State private var angles = CaseAngles.rest
    @State private var dragStart: CaseAngles?
    @State private var hover = CGPoint.zero
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private typealias Metrics = ShellLayout.GameCase
    private static let hoverCentre: CGFloat = 0.5

    var body: some View {
        VStack(spacing: Metrics.buttonTop * scale) {
            area
            CaseTurnButton(isShowingBack: CaseSpin.isShowingBack(yaw: angles.yaw), hint: turnHint) {
                withAnimation(turnAnimation) { angles = CaseSpin.turnedOver(angles) }
            }
        }
    }

    private var areaSize: CGSize {
        CGSize(width: Metrics.width + Metrics.areaExtraWidth, height: Metrics.height + Metrics.areaExtraHeight)
    }

    private var area: some View {
        let displayed = CaseSpin.displayed(angles, hover: hover)
        return ZStack(alignment: .bottom) {
            Ellipse()
                .fill(Theme.floor)
                .frame(
                    width: Metrics.width * CGFloat(CaseSpin.floorWidthShare(yaw: displayed.yaw)),
                    height: Metrics.floorHeight
                )
                .blur(radius: Metrics.floorBlur)
                .padding(.bottom, Metrics.floorBottom)
                .animation(reduceMotion ? nil : Motion.settle(Motion.Duration.rise), value: displayed.yaw)
            GameCaseBody(artwork: artwork, angles: displayed)
                .animation(isDragging || reduceMotion ? nil : turnAnimation, value: hover)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .floatIdle()
        }
        .frame(width: areaSize.width, height: areaSize.height)
        .scaleEffect(scale)
        .frame(width: areaSize.width * scale, height: areaSize.height * scale)
        .contentShape(Rectangle())
        .gesture(drag)
        .onContinuousHover { phase in
            guard !isDragging else { return }
            switch phase {
            case let .active(location):
                hover = CGPoint(
                    x: location.x / (areaSize.width * scale) - Self.hoverCentre,
                    y: location.y / (areaSize.height * scale) - Self.hoverCentre
                )
            case .ended:
                hover = .zero
            }
        }
        .pointerStyle(isDragging ? .grabActive : .grabIdle)
        .accessibilityElement()
        .accessibilityLabel(Text("\(artwork.title) game case"))
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(named: CaseSpin.isShowingBack(yaw: angles.yaw) ? "Flip to the front" : "Turn it over") {
            angles = CaseSpin.turnedOver(angles)
        }
    }

    private var isDragging: Bool {
        dragStart != nil
    }

    private var turnAnimation: Animation? {
        reduceMotion ? nil : Motion.settle(Motion.Duration.turn)
    }

    private var drag: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let start = dragStart ?? angles
                if dragStart == nil {
                    dragStart = start
                }
                angles = CaseSpin.dragged(from: start, translation: value.translation)
            }
            .onEnded { _ in
                dragStart = nil
                withAnimation(turnAnimation) { angles = CaseSpin.settled(angles) }
            }
    }
}

#Preview {
    AppearancePreviewPair {
        GameCaseObject(
            artwork: .preview,
            turnHint: "· or drag it · 11h 40m played",
            scale: ShellLayout.GameCase.minimumScale
        )
        .padding(DesignTokens.Spacing.xl)
    }
}
