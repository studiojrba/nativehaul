import Foundation

/// Finds CrossOver bottles and game install folders. Live: ``CrossOverBottleScanner``; mock: ``MockCrossOverScanner``.
protocol CrossOverScanning: Sendable {
    /// Lists bottles under `bottlesRoot` and plausible game folders in each bottle's `Program Files`.
    /// A missing bottles root yields an empty result, not an error.
    func scanBottles(at bottlesRoot: String) -> CrossOverScanResult
}
