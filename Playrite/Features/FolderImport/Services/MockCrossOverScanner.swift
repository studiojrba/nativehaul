import Foundation

/// Mock ``CrossOverScanning`` returning a fixed result.
struct MockCrossOverScanner: CrossOverScanning {
    private static let installFolder = "/Users/demo/Bottles/Games/drive_c/Program Files/Lanternfall"

    /// Result to return.
    var result = CrossOverScanResult(
        bottles: ["Games"],
        installs: [CrossOverInstall(
            name: "Lanternfall",
            bottle: "Games",
            folderPath: installFolder,
            executablePath: installFolder + "/Lanternfall.exe"
        )]
    )

    func scanBottles(at _: String) -> CrossOverScanResult {
        result
    }
}
