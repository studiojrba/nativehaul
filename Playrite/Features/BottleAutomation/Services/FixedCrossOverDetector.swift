import Foundation

/// Mock ``CrossOverDetecting`` returning a fixed answer.
struct FixedCrossOverDetector: CrossOverDetecting {
    /// The toolchain to report (`nil` = not installed).
    let toolchain: CrossOverToolchain?

    /// A detector that finds CrossOver at the standard path.
    static let installed = FixedCrossOverDetector(
        toolchain: CrossOverToolchain(configuration: .standard, version: "25.0")
    )

    func detect() -> CrossOverToolchain? {
        toolchain
    }
}
