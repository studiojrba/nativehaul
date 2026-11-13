import Foundation

extension CubicBezier {
    /// Newton iterations before falling back to bisection.
    private static let newtonIterations = 8
    /// Bisection iterations (plenty for sub-pixel precision).
    private static let bisectionIterations = 30
    /// Close enough.
    private static let tolerance = 1e-6
    /// Bezier polynomial coefficients.
    private static let three = 3.0
    private static let two = 2.0

    /// The curve's progress at time `x` (0…1), as CSS evaluates `cubic-bezier()`: solve for the parameter whose x is
    /// `x`, return its y.
    func value(at x: Double) -> Double {
        let clamped = min(max(x, 0), 1)
        if clamped == 0 || clamped == 1 {
            return clamped
        }
        return sample(y1, y2, at: parameter(for: clamped))
    }

    private func parameter(for x: Double) -> Double {
        var param = x
        for _ in 0 ..< Self.newtonIterations {
            let error = sample(x1, x2, at: param) - x
            if abs(error) < Self.tolerance {
                return param
            }
            let slope = derivative(x1, x2, at: param)
            guard abs(slope) > Self.tolerance else { break }
            param -= error / slope
        }
        var low = 0.0
        var high = 1.0
        param = x
        for _ in 0 ..< Self.bisectionIterations {
            let value = sample(x1, x2, at: param)
            if abs(value - x) < Self.tolerance {
                return param
            }
            if value < x {
                low = param
            } else {
                high = param
            }
            param = (low + high) / Self.two
        }
        return param
    }

    /// One coordinate of the curve from (0,0) via `p1`, `p2` to (1,1) at parameter `param`.
    private func sample(_ p1: Double, _ p2: Double, at param: Double) -> Double {
        let inverse = 1 - param
        return Self.three * inverse * inverse * param * p1 + Self
            .three * inverse * param * param * p2 + param * param * param
    }

    private func derivative(_ p1: Double, _ p2: Double, at param: Double) -> Double {
        let inverse = 1 - param
        return Self.three * inverse * inverse * p1 + Self.two * Self.three * inverse * param * (p2 - p1)
            + Self.three * param * param * (1 - p2)
    }
}
