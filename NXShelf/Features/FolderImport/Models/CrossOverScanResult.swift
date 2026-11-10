import Foundation

/// Everything found in CrossOver: bottles and plausible game install folders.
struct CrossOverScanResult: Equatable, Sendable {
    /// Bottle names (folder names), sorted.
    var bottles: [String] = []
    /// Install folders that look like games, after the skip-list.
    var installs: [CrossOverInstall] = []
}
