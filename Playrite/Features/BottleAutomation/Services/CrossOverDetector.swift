import Foundation

/// Live ``CrossOverDetecting``: looks for CrossOver.app in /Applications, then ~/Applications, and requires its
/// `cxbottle` and `wine` tools to be executable.
struct CrossOverDetector: CrossOverDetecting {
    private let files: any FileOperating
    private let candidates: [String]

    /// Creates the detector.
    init(
        files: any FileOperating,
        candidates: [String] = ["/Applications/CrossOver.app", "~/Applications/CrossOver.app"]
    ) {
        self.files = files
        self.candidates = candidates.map { ($0 as NSString).expandingTildeInPath }
    }

    func detect() -> CrossOverToolchain? {
        for appPath in candidates {
            let configuration = CrossOverLaunchConfiguration(crossOverAppPath: appPath)
            guard files.isExecutableFile(atPath: configuration.cxbottleExecutablePath),
                  files.isExecutableFile(atPath: configuration.wineExecutablePath)
            else { continue }
            return CrossOverToolchain(configuration: configuration, version: version(of: appPath))
        }
        return nil
    }

    private func version(of appPath: String) -> String? {
        let plistPath = (appPath as NSString).appendingPathComponent("Contents/Info.plist")
        guard let data = try? files.readData(atPath: plistPath),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        else { return nil }
        return plist["CFBundleShortVersionString"] as? String
    }
}
