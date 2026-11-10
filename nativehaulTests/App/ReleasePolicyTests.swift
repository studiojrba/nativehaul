import Foundation
@testable import nativehaul
import Testing

/// ADR 0049: the release ships its licences, bundles nothing beyond the audited dependencies, and talks only to the
/// hosts `docs/PRIVACY.md` lists (no telemetry).
struct ReleasePolicyTests {
    private static let repoRoot = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()

    /// Frameworks the licence audit (`docs/LICENSE_AUDIT.md`) allows inside the app bundle.
    private static let auditedFrameworks: Set<String> = ["Sparkle.framework"]

    @Test func everyHostInTheSourceIsDocumentedInThePrivacyPolicy() throws {
        let policy = try String(contentsOf: Self.repoRoot.appending(path: "docs/PRIVACY.md"), encoding: .utf8)
        let pattern = try Regex(#"https?://([A-Za-z0-9.-]+)"#)
        var undocumented: Set<String> = []
        let sources = Self.repoRoot.appending(path: "nativehaul")
        let enumerator = FileManager.default.enumerator(at: sources, includingPropertiesForKeys: nil)
        while let url = enumerator?.nextObject() as? URL {
            guard ["swift", "json"].contains(url.pathExtension) else { continue }
            let text = try String(contentsOf: url, encoding: .utf8)
            for match in text.matches(of: pattern) {
                guard let host = match.output[1].substring.map(String.init) else { continue }
                if !policy.contains("`\(host)`") {
                    undocumented.insert(host)
                }
            }
        }
        #expect(undocumented.isEmpty, "Hosts missing from docs/PRIVACY.md: \(undocumented.sorted())")
    }

    @Test func theAppShipsItsLicenceAndNotices() throws {
        let licence = try #require(Bundle.main.url(forResource: "LICENSE", withExtension: nil))
        let notices = try #require(Bundle.main.url(forResource: "THIRD_PARTY_NOTICES", withExtension: "md"))
        #expect(try String(contentsOf: licence, encoding: .utf8).contains("Studio Jrba inc."))
        #expect(try String(contentsOf: notices, encoding: .utf8).contains("nxnative"))
    }

    @Test func onlyAuditedFrameworksAreBundled() {
        // No Frameworks folder at all means nothing is bundled.
        let frameworks = (try? Bundle.main.privateFrameworksURL.map {
            try FileManager.default.contentsOfDirectory(atPath: $0.path(percentEncoded: false))
        }) ?? []
        #expect(Set(frameworks).isSubset(of: Self.auditedFrameworks), "Unaudited: \(frameworks)")
    }

    @Test func everyAuditedFrameworkHasANotice() throws {
        let notices = try String(
            contentsOf: Self.repoRoot.appending(path: "THIRD_PARTY_NOTICES.md"), encoding: .utf8
        )
        for framework in Self.auditedFrameworks {
            #expect(notices.contains(framework.replacingOccurrences(of: ".framework", with: "")))
        }
    }
}
