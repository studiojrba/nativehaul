import Foundation
@testable import Playrite

enum NXNativeFixtures {
    static let engine = "/tools/nxnative"
    static let source = "/stage/Tideborn.nsp"
    static let sourceBytes = 1000
    static let title = TitleInfo(titleID: "0100ABCD00010000", name: "Tideborn", architecture: .bit64)

    static var configuration: EngineConfiguration {
        EngineConfiguration(
            isEnabled: true, enginePath: engine, argumentTemplate: "--in {input} --out {output} --name {title}",
            stagingDirectory: "/stage", workRoot: "/work", outputDirectory: "/games",
            hiddenLibraryFolderName: ".nxnative-lib", spaceMultiplier: 3
        )
    }

    static func files() -> InMemoryFileOperations {
        let files = InMemoryFileOperations()
        files.addFile(engine, contents: Data("#!/bin/sh".utf8), executable: true)
        files.addFile(source, contents: Data(repeating: 1, count: sourceBytes))
        files.addFile("/stage/readme.txt")
        files.addDirectory("/games")
        return files
    }

    static let script = """
    #!/bin/sh
    TITLE_ID="$1"
    check_retail_profile "$TITLE_ID" || exit 1
    convert "$TITLE_ID"
    """
}
