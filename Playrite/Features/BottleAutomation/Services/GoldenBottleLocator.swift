import Foundation

/// Reads CrossOver's bottles to find a Steam that is signed in to a given account. Read-only.
struct GoldenBottleLocator: Sendable {
    private static let steamFolder = "drive_c/Program Files (x86)/Steam"
    private static let manifestPrefix = "appmanifest_"
    private let files: any FileOperating
    private let bottlesRoot: String

    /// Creates the locator.
    init(files: any FileOperating, locations: CrossOverLocations = .standard) {
        self.files = files
        bottlesRoot = (locations.bottlesRoot as NSString).expandingTildeInPath
    }

    /// The plan for a bottle by name.
    func plan(for name: String) -> BottlePlan {
        BottlePlan(bottleName: name, bottlePath: (bottlesRoot as NSString).appendingPathComponent(name))
    }

    /// Bottle names, sorted.
    func bottleNames() -> [String] {
        ((try? files.contentsOfDirectory(atPath: bottlesRoot)) ?? [])
            .filter { !$0.hasPrefix(".") && files.isDirectory(atPath: plan(for: $0).bottlePath) }
            .sorted()
    }

    /// The SteamID64 Steam in `plan` last signed in with, if any.
    func signedInSteamID(in plan: BottlePlan) -> String? {
        let path = (plan.steamRoot as NSString).appendingPathComponent("config/loginusers.vdf")
        guard let data = try? files.readData(atPath: path), let text = String(bytes: data, encoding: .utf8) else {
            return nil
        }
        return SteamLoginUsers.mostRecentSteamID(in: text)
    }

    /// Whether the bottle's Steam has no games installed (so clones of it stay small).
    func isLean(_ plan: BottlePlan) -> Bool {
        let steamapps = (plan.steamRoot as NSString).appendingPathComponent("steamapps")
        let names = (try? files.contentsOfDirectory(atPath: steamapps)) ?? []
        return !names.contains { $0.hasPrefix(Self.manifestPrefix) }
    }

    /// A bottle whose Steam is signed in to `steamID`, preferring lean ones.
    func findSignedInBottle(for steamID: String) -> (name: String, isLean: Bool)? {
        let matches = bottleNames().filter { signedInSteamID(in: plan(for: $0)) == steamID }
        if let lean = matches.first(where: { isLean(plan(for: $0)) }) {
            return (lean, true)
        }
        return matches.first.map { ($0, false) }
    }
}
