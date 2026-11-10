import Foundation

/// The parts of a GitHub release NX Shelf reads (`/repos/{owner}/{repo}/releases/latest`).
struct GitHubRelease: Decodable, Sendable {
    /// Release asset.
    struct Asset: Decodable, Sendable {
        /// File name.
        let name: String
        /// Direct download URL.
        let browserDownloadUrl: URL
        /// "sha256:<hex>", when GitHub publishes it.
        let digest: String?
    }

    /// Tag ("v2.3.1").
    let tagName: String
    /// Assets.
    let assets: [Asset]
    /// Release page.
    let htmlUrl: URL?
}
