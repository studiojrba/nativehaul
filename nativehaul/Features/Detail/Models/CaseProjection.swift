import QuartzCore

/// Projects a face of the case into 2D (spec §3.3): the face's place on the box, the box's turn, and CSS-style
/// perspective, as one `CATransform3D` for SwiftUI's `projectionEffect`. Coordinates follow CSS: x right, y down, z
/// toward the viewer; angles in degrees, positive as CSS `rotateX` / `rotateY`.
///
/// Each face is laid out centred on the box's centre; the transform moves it out to its side, turns the box, and
/// projects it. A face is drawn only when it faces the viewer.
struct CaseProjection: Sendable {
    /// Face width.
    let width: CGFloat
    /// Face height.
    let height: CGFloat
    /// Depth.
    let depth: CGFloat
    /// Perspective distance.
    let perspective: CGFloat

    private static let quarterTurn: CGFloat = 90
    private static let halfTurn: CGFloat = 180
    private static let half: CGFloat = 2

    /// The transform for `face` (in the face view's own coordinates) at `angles`.
    func transform(for face: CaseFace, at angles: CaseAngles) -> CATransform3D {
        let size = face.size(width: width, height: height, depth: depth)
        let toCentre = CATransform3DMakeTranslation(-size.width / Self.half, -size.height / Self.half, 0)
        let back = CATransform3DMakeTranslation(size.width / Self.half, size.height / Self.half, 0)
        var projection = CATransform3DIdentity
        projection.m34 = -1 / perspective
        return [toCentre, placement(of: face), boxTurn(angles), projection, back].reduce(CATransform3DIdentity) {
            CATransform3DConcat($0, $1)
        }
    }

    /// Whether `face` faces the viewer at `angles` (its outward normal points toward the eye).
    func isVisible(_ face: CaseFace, at angles: CaseAngles) -> Bool {
        let turn = CATransform3DConcat(placement(of: face), boxTurn(angles))
        let centre = Self.apply(turn, to: SIMD3(0, 0, 0))
        let normal = Self.apply(turn, to: SIMD3(0, 0, 1)) - centre
        let toEye = SIMD3(0, 0, Double(perspective)) - centre
        return (normal * toEye).sum() > 0
    }

    /// The faces facing the viewer at `angles`.
    func visibleFaces(at angles: CaseAngles) -> [CaseFace] {
        CaseFace.allCases.filter { isVisible($0, at: angles) }
    }

    /// Moves a face from the box's centre out to its side (CSS `rotate… translateZ(…)`).
    private func placement(of face: CaseFace) -> CATransform3D {
        switch face {
        case .front: out(depth)
        case .back: CATransform3DConcat(out(depth), Self.rotateY(Self.halfTurn))
        case .spine: CATransform3DConcat(out(width), Self.rotateY(Self.quarterTurn))
        case .side: CATransform3DConcat(out(width), Self.rotateY(-Self.quarterTurn))
        case .top: CATransform3DConcat(out(height), Self.rotateX(Self.quarterTurn))
        case .bottom: CATransform3DConcat(out(height), Self.rotateX(-Self.quarterTurn))
        }
    }

    private func out(_ extent: CGFloat) -> CATransform3D {
        CATransform3DMakeTranslation(0, 0, extent / Self.half)
    }

    /// CSS `rotateX(pitch) rotateY(yaw)`: yaw first, then pitch.
    private func boxTurn(_ angles: CaseAngles) -> CATransform3D {
        CATransform3DConcat(Self.rotateY(CGFloat(angles.yaw)), Self.rotateX(CGFloat(angles.pitch)))
    }

    /// CSS `rotateY` for row vectors: x' = x·cos + z·sin, z' = −x·sin + z·cos.
    private static func rotateY(_ degrees: CGFloat) -> CATransform3D {
        let radians = degrees * .pi / halfTurn
        var matrix = CATransform3DIdentity
        matrix.m11 = cos(radians)
        matrix.m13 = -sin(radians)
        matrix.m31 = sin(radians)
        matrix.m33 = cos(radians)
        return matrix
    }

    /// CSS `rotateX` for row vectors (y down): y' = y·cos − z·sin, z' = y·sin + z·cos.
    private static func rotateX(_ degrees: CGFloat) -> CATransform3D {
        let radians = degrees * .pi / halfTurn
        var matrix = CATransform3DIdentity
        matrix.m22 = cos(radians)
        matrix.m23 = sin(radians)
        matrix.m32 = -sin(radians)
        matrix.m33 = cos(radians)
        return matrix
    }

    /// `point · matrix` for an affine (non-projective) transform.
    private static func apply(_ matrix: CATransform3D, to point: SIMD3<Double>) -> SIMD3<Double> {
        let x = Double(matrix.m11) * point.x + Double(matrix.m21) * point.y + Double(matrix.m31) * point.z
        let y = Double(matrix.m12) * point.x + Double(matrix.m22) * point.y + Double(matrix.m32) * point.z
        let depth = Double(matrix.m13) * point.x + Double(matrix.m23) * point.y + Double(matrix.m33) * point.z
        return SIMD3(x + Double(matrix.m41), y + Double(matrix.m42), depth + Double(matrix.m43))
    }
}
