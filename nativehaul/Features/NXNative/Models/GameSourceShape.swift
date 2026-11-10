import Foundation

/// What the user picked in Add Build, in the shapes nxnative's `build_ipa_from_nsp.py` takes (ADR 0022).
///
/// Switch games come as packages (`.nsp`/`.xci`/`.nsz`/`.xcz`), which need `prod.keys`. Switch 2 games come as a
/// `.nup` container or a dump of its files, which are not encrypted and need no keys. The dump layouts mirror
/// nxnative's `is_dump`: `base/exefs/main.npdm` with `base/romfs/`, `exefs/main.npdm` with `romfs/`, or
/// `updates/<version>/romfs/` (with a base, or its own `exefs/main.npdm`). Packages beside a dump win, as in nxnative.
enum GameSourceShape: Equatable, Sendable {
    /// One package file; nxnative builds the folder holding it (base game, update and DLC together).
    case packageFile
    /// A folder holding one game's packages.
    case packageFolder
    /// A Switch 2 `.nup` container (nxnative takes the file itself).
    case nup
    /// A Switch 2 dump folder.
    case dumpFolder
    /// Nothing nxnative can build.
    case unsupported

    /// The Switch 2 container extension.
    static let nupExtension = "nup"

    /// Classifies `path`.
    static func detect(_ path: String, files: any FileOperating) -> Self {
        guard files.fileExists(atPath: path) else { return .unsupported }
        let pathExtension = (path as NSString).pathExtension.lowercased()
        guard files.isDirectory(atPath: path) else {
            if pathExtension == nupExtension {
                return .nup
            }
            return StagedFileKind(pathExtension: pathExtension) == .titleFile ? .packageFile : .unsupported
        }
        let names = ((try? files.contentsOfDirectory(atPath: path)) ?? []).filter { !$0.hasPrefix("._") }
        let extensions = names.map { ($0 as NSString).pathExtension.lowercased() }
        // NSPs beside a dump are built as NSPs (nxnative 1.8.2), so packages win.
        if extensions.contains(where: { StagedFileKind(pathExtension: $0) == .titleFile }) {
            return .packageFolder
        }
        if isDump(path, files: files) {
            return .dumpFolder
        }
        return extensions.contains(nupExtension) ? .nup : .unsupported
    }

    /// Whether this is a Switch 2 game.
    var isSwitch2: Bool {
        self == .nup || self == .dumpFolder
    }

    /// Whether nxnative needs `prod.keys` for it.
    var needsKeys: Bool {
        self == .packageFile || self == .packageFolder
    }

    /// The path handed to nxnative: the folder for a package file, otherwise what was picked.
    func engineInput(for path: String) -> String {
        self == .packageFile ? (path as NSString).deletingLastPathComponent : path
    }

    private static func isDump(_ folder: String, files: any FileOperating) -> Bool {
        let path: (String) -> String = { (folder as NSString).appendingPathComponent($0) }
        let hasBaseCode = files.fileExists(atPath: path("base/exefs/main.npdm"))
        if hasBaseCode, files.isDirectory(atPath: path("base/romfs")) {
            return true
        }
        if files.fileExists(atPath: path("exefs/main.npdm")), files.isDirectory(atPath: path("romfs")) {
            return true
        }
        let versions = ((try? files.contentsOfDirectory(atPath: path("updates"))) ?? [])
            .filter { !$0.isEmpty && $0.allSatisfy(\.isNumber) }
        return versions.contains { version in
            let update = path("updates/\(version)")
            guard files.isDirectory(atPath: update + "/romfs") else { return false }
            return hasBaseCode || files.fileExists(atPath: update + "/exefs/main.npdm")
        }
    }
}
