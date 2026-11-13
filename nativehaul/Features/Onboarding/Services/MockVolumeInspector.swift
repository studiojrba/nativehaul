import Foundation

/// Mock ``VolumeInspecting`` with fixed volumes, for previews and tests.
struct MockVolumeInspector: VolumeInspecting {
    /// The volume every path is on.
    var startup: VolumeInfo?
    /// External drives.
    var externals: [VolumeInfo] = []

    func volume(containing _: String) -> VolumeInfo? {
        startup
    }

    func externalVolumes() -> [VolumeInfo] {
        externals
    }

    /// A preview Mac: 412 GB free of 994 GB, no external drive.
    static let preview = MockVolumeInspector(startup: VolumeInfo(
        name: "Macintosh HD",
        mountPath: "/",
        freeBytes: previewFree,
        totalBytes: previewTotal
    ))

    private static let previewFree: Int64 = 412_000_000_000
    private static let previewTotal: Int64 = 994_000_000_000
}
