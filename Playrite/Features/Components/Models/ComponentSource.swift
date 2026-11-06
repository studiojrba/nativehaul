import Foundation

/// Where a component's official Mac build comes from.
enum ComponentSource: Codable, Equatable, Sendable {
    /// The latest GitHub release of `owner/repo`, taking the asset whose name matches `assetPattern` (a regex).
    case gitHub(owner: String, repo: String, assetPattern: String)
    /// A pinned official download (for projects whose releases don't carry the Mac build). The catalog states the
    /// version the URL serves, and an optional published SHA-256.
    case pinned(url: URL, version: String, sha256: String?)

    private enum CodingKeys: String, CodingKey {
        case kind, owner, repo, assetPattern, url, version, sha256
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(String.self, forKey: .kind) {
        case "github":
            self = try .gitHub(
                owner: container.decode(String.self, forKey: .owner),
                repo: container.decode(String.self, forKey: .repo),
                assetPattern: container.decode(String.self, forKey: .assetPattern)
            )
        default:
            self = try .pinned(
                url: container.decode(URL.self, forKey: .url),
                version: container.decode(String.self, forKey: .version),
                sha256: container.decodeIfPresent(String.self, forKey: .sha256)
            )
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .gitHub(owner, repo, pattern):
            try container.encode("github", forKey: .kind)
            try container.encode(owner, forKey: .owner)
            try container.encode(repo, forKey: .repo)
            try container.encode(pattern, forKey: .assetPattern)
        case let .pinned(url, version, sha256):
            try container.encode("pinned", forKey: .kind)
            try container.encode(url, forKey: .url)
            try container.encode(version, forKey: .version)
            try container.encodeIfPresent(sha256, forKey: .sha256)
        }
    }
}
