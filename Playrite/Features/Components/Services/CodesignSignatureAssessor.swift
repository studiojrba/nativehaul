import Foundation

/// Live ``SignatureAssessing`` using Apple's own tools: `codesign --verify`, `codesign -dv` for the team and
/// `spctl --assess` for notarization. Read-only; it never changes attributes or Gatekeeper settings.
struct CodesignSignatureAssessor: SignatureAssessing {
    private static let codesign = "/usr/bin/codesign"
    private static let spctl = "/usr/sbin/spctl"
    private let runner: any CommandRunning

    /// Creates the assessor.
    init(runner: any CommandRunning) {
        self.runner = runner
    }

    func assess(appAt path: String) async -> SignatureStatus {
        guard let verify = try? await runner.run(executable: Self.codesign, arguments: [
            "--verify", "--deep", "--strict", path,
        ]) else { return .invalid("couldn't run codesign") }
        if !verify.succeeded {
            return verify.output.contains("not signed") ? .unsigned : .invalid(Self.firstLine(verify.output))
        }
        let details = await (try? runner.run(executable: Self.codesign, arguments: ["-dv", "--verbose=2", path]))?
            .output ?? ""
        guard let team = Self.team(from: details) else { return .unsigned }
        let gatekeeper = try? await runner.run(executable: Self.spctl, arguments: [
            "--assess", "--type", "execute", "-vv", path,
        ])
        let isNotarized = gatekeeper?.succeeded == true && gatekeeper?.output.contains("Notarized") == true
        return isNotarized ? .notarized(team: team) : .signed(team: team)
    }

    /// The signer from `codesign -dv` output ("Developer ID Application: Name (TEAMID)").
    static func team(from output: String) -> String? {
        let prefix = "Authority=Developer ID Application: "
        guard let line = output.split(separator: "\n").first(where: { $0.hasPrefix(prefix) }) else { return nil }
        return String(line.dropFirst(prefix.count))
    }

    private static func firstLine(_ text: String) -> String {
        text.split(separator: "\n").first.map(String.init) ?? "unknown reason"
    }
}
