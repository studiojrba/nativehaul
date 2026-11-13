import SwiftUI

/// The case as a 3D box (spec §3.3): each face is laid out at the box's centre and projected into place by
/// ``CaseProjection``; only faces turned toward the viewer are drawn. Animatable, so the faces swap at the right moment
/// while it turns.
struct GameCaseBody: View, Animatable {
    /// What is printed on the case.
    let artwork: CaseArtwork
    /// The pose drawn.
    var angles: CaseAngles

    private typealias Metrics = ShellLayout.GameCase
    private static let projection = CaseProjection(
        width: Metrics.width,
        height: Metrics.height,
        depth: Metrics.depth,
        perspective: Metrics.perspective
    )

    /// Yaw and pitch interpolate together.
    nonisolated var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(angles.yaw, angles.pitch) }
        set { angles = CaseAngles(yaw: newValue.first, pitch: newValue.second) }
    }

    var body: some View {
        ZStack {
            ForEach(Self.projection.visibleFaces(at: angles), id: \.self) { face in
                let size = face.size(width: Metrics.width, height: Metrics.height, depth: Metrics.depth)
                faceView(face)
                    .frame(width: size.width, height: size.height)
                    .projectionEffect(ProjectionTransform(Self.projection.transform(for: face, at: angles)))
            }
        }
        .frame(width: Metrics.width, height: Metrics.height)
    }

    @ViewBuilder
    private func faceView(_ face: CaseFace) -> some View {
        switch face {
        case .front:
            CaseFrontFace(artwork: artwork).overlay(CaseSheen(facing: angles.yaw))
        case .back:
            CaseBackFace(artwork: artwork).overlay(CaseSheen(facing: angles.yaw + CaseSpin.halfTurn))
        case .spine:
            CaseSpineFace(artwork: artwork)
        case .side:
            artwork.colors.side.color
        case .top:
            artwork.colors.top.color
        case .bottom:
            artwork.colors.bottom.color
        }
    }
}

#Preview {
    GameCaseBody(artwork: .preview, angles: .rest)
        .padding(KitMetrics.Spacing.page)
}
