import Foundation

/// Reads the newest official build: GitHub's "latest release" API, or the catalog's pinned entry (no network).
struct ComponentReleaseFetcher: Sendable {
    private static let apiBase = "https://api.github.com/repos"
    private static let digestPrefix = "sha256:"
    private static let okLowerBound = 200
    private static let okUpperBound = 300
    private static let notFound = 404
    private let http: any HTTPClient

    /// Creates the fetcher.
    init(http: any HTTPClient) {
        self.http = http
    }

    /// The latest release of `entry`.
    func latest(for entry: ComponentEntry) async throws -> ComponentRelease {
        switch entry.source {
        case let .pinned(url, version, sha256):
            return ComponentRelease(version: version, downloadURL: url, sha256: sha256)
        case let .gitHub(owner, repo, pattern):
            guard let release = try await latestRelease(owner: owner, repo: repo) else {
                throw ComponentError.releaseUnavailable
            }
            let regex = try? NSRegularExpression(pattern: pattern)
            guard let asset = release.assets.first(where: { asset in
                regex?.firstMatch(in: asset.name, range: NSRange(asset.name.startIndex..., in: asset.name)) != nil
            }) else { throw ComponentError.noMacAsset }
            let digest = asset.digest.flatMap {
                $0.hasPrefix(Self.digestPrefix) ? String($0.dropFirst(Self.digestPrefix.count)).lowercased() : nil
            }
            return ComponentRelease(version: release.tagName, downloadURL: asset.browserDownloadUrl, sha256: digest)
        }
    }

    /// The latest release of a repo, or `nil` when it has none.
    func latestRelease(owner: String, repo: String) async throws -> GitHubRelease? {
        guard let url = URL(string: "\(Self.apiBase)/\(owner)/\(repo)/releases/latest") else { return nil }
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("Retriever", forHTTPHeaderField: "User-Agent")
        let (data, response) = try await http.data(for: request)
        if response.statusCode == Self.notFound {
            return nil
        }
        guard (Self.okLowerBound ..< Self.okUpperBound).contains(response.statusCode) else {
            throw ComponentError.releaseUnavailable
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(GitHubRelease.self, from: data)
    }
}
