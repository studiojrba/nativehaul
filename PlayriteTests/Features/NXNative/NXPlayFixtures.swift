import Foundation
@testable import Playrite

/// J.R's machine as ADR 0022 sees it: NX Play's nxnative checkout and Python environment, his keys, an empty output.
enum NXPlayFixtures {
    static let home = "/Users/jr"
    static let repository = "\(home)/Library/Application Support/NX Play/nxnative"
    static let script = "\(repository)/scripts/build_ipa_from_nsp.py"
    static let venv = "\(home)/Library/Application Support/NX Play/venv"
    static let keys = "\(home)/Switch/ProdKeys.NET-v22.5.0/prod.keys"
    static let work = "/work/job"

    /// The file tree, optionally without the Python environment or the keys.
    static func jrFiles(withEnvironment: Bool = true, withKeys: Bool = true) -> InMemoryFileOperations {
        let files = InMemoryFileOperations()
        files.addFile(script, contents: Data("#!/usr/bin/env python3".utf8), executable: true)
        if withEnvironment {
            files.addFile("\(venv)/bin/python3", executable: true)
        }
        if withKeys {
            files.addFile(keys)
        }
        files.addDirectory("/games")
        return files
    }

    /// Adds a Switch 2 dump (`base/exefs/main.npdm` + `base/romfs/`).
    static func addSwitch2Dump(_ files: InMemoryFileOperations, at folder: String) {
        files.addFile(
            "\(folder)/base/exefs/main.npdm",
            contents: Data(repeating: 1, count: NXNativeFixtures.sourceBytes)
        )
        files.addDirectory("\(folder)/base/romfs")
    }

    /// The untouched install: no overrides at all, everything detected.
    @MainActor
    static func resolved(_ files: InMemoryFileOperations) -> EngineConfiguration {
        var configuration = EngineConfiguration()
        configuration.workRoot = "/work"
        configuration.outputDirectory = "/games"
        return NXNativeLocator(files: files, homeDirectory: home).resolve(configuration)
    }
}
