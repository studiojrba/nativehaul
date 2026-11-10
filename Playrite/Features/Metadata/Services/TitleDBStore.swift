import Foundation

/// Live ``TitleDBStoring`` (ADR 0038). Downloads titledb's US English region file once, keeps a compact index of it
/// in `~/Library/Application Support/Playrite/TitleDB/`, and refreshes it at most every 30 days. A failed refresh
/// keeps using the older cache; with no cache at all, the dataset is simply absent for the session.
actor TitleDBStore: TitleDBStoring {
    /// Region file used: US English, the region whose listings match the library's English titles.
    static let region = "US.en"
    /// Oldest a cached index may be before a refresh is tried (30 days).
    static let maxAge: TimeInterval = 2_592_000
    /// The region file on titledb's GitHub repository.
    static let sourceURL = URL(string: "https://raw.githubusercontent.com/blawar/titledb/master/\(region).json")
    private static let okRange = 200 ..< 300
    /// The file is about 90 MB, so it gets a generous timeout.
    private static let downloadTimeout: TimeInterval = 600

    private let http: any HTTPClient
    private let cacheFile: URL
    private let now: @Sendable () -> Date
    private var loading: Task<TitleDBIndex?, Never>?

    /// Creates the store.
    init(
        http: any HTTPClient,
        cacheFile: URL = TitleDBStore.defaultCacheFile(),
        now: @escaping @Sendable () -> Date = Date.init
    ) {
        self.http = http
        self.cacheFile = cacheFile
        self.now = now
    }

    /// `~/Library/Application Support/Playrite/TitleDB/US.en.index.json`.
    static func defaultCacheFile() -> URL {
        URL.applicationSupportDirectory.appending(path: "Playrite/TitleDB/\(region).index.json")
    }

    func index() async -> TitleDBIndex? {
        if let loading {
            return await loading.value
        }
        let task = Task { await load() }
        loading = task
        return await task.value
    }

    private func load() async -> TitleDBIndex? {
        let cached = readCache()
        if let cached, now().timeIntervalSince(cached.fetchedAt) < Self.maxAge {
            return cached
        }
        guard let fresh = await download() else { return cached }
        writeCache(fresh)
        return fresh
    }

    private func download() async -> TitleDBIndex? {
        guard let url = Self.sourceURL else { return nil }
        var request = URLRequest(url: url)
        request.timeoutInterval = Self.downloadTimeout
        guard let (data, response) = try? await http.data(for: request), Self.okRange.contains(response.statusCode)
        else { return nil }
        return try? TitleDBIndex.build(regionFile: data, region: Self.region, fetchedAt: now())
    }

    private func readCache() -> TitleDBIndex? {
        guard let data = try? Data(contentsOf: cacheFile) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(TitleDBIndex.self, from: data)
    }

    private func writeCache(_ index: TitleDBIndex) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(index) else { return }
        try? FileManager.default.createDirectory(
            at: cacheFile.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try? data.write(to: cacheFile, options: .atomic)
    }
}
