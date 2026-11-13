import Foundation

/// Live ``VolumeInspecting`` over `URL` resource values. Reads volume metadata only — never a folder's contents.
struct LiveVolumeInspector: VolumeInspecting {
    private static let keys: Set<URLResourceKey> = [
        .volumeNameKey, .volumeURLKey, .volumeAvailableCapacityForImportantUsageKey, .volumeTotalCapacityKey,
        .volumeIsInternalKey, .volumeIsLocalKey, .volumeIsReadOnlyKey, .volumeIsRootFileSystemKey,
    ]

    func volume(containing path: String) -> VolumeInfo? {
        var url = URL(fileURLWithPath: (path as NSString).expandingTildeInPath)
        while !FileManager.default.fileExists(atPath: url.path), url.pathComponents.count > 1 {
            url.deleteLastPathComponent()
        }
        return info(for: url)
    }

    func externalVolumes() -> [VolumeInfo] {
        let urls = FileManager.default.mountedVolumeURLs(
            includingResourceValuesForKeys: Array(Self.keys),
            options: [.skipHiddenVolumes]
        ) ?? []
        return urls.compactMap { url in
            guard let values = try? url.resourceValues(forKeys: Self.keys),
                  values.volumeIsRootFileSystem != true,
                  values.volumeIsInternal == false,
                  values.volumeIsLocal == true,
                  values.volumeIsReadOnly != true
            else { return nil }
            return info(for: url)
        }
    }

    private func info(for url: URL) -> VolumeInfo? {
        guard let values = try? url.resourceValues(forKeys: Self.keys) else { return nil }
        return VolumeInfo(
            name: values.volumeName ?? url.lastPathComponent,
            mountPath: values.volume?.path ?? url.path,
            freeBytes: values.volumeAvailableCapacityForImportantUsage ?? 0,
            totalBytes: Int64(values.volumeTotalCapacity ?? 0)
        )
    }
}
