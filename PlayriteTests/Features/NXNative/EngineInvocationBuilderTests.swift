import Foundation
@testable import Playrite
import Testing

struct EngineInvocationBuilderTests {
    typealias Fix = NXNativeFixtures

    @Test func substitutesPlaceholdersAfterSplitting() {
        var title = Fix.title
        title.name = "Moon Well: Deluxe"
        let job = BuildJob(sourcePath: "/stage/My Game.nsp", title: title)
        let invocation = EngineInvocationBuilder.invocation(
            for: job,
            configuration: Fix.configuration,
            workDirectory: "/work/1"
        )
        #expect(invocation.executable == Fix.engine)
        #expect(invocation.arguments == [
            "--in",
            "/stage/My Game.nsp",
            "--out",
            "/work/1",
            "--name",
            "Moon Well: Deluxe",
        ])
        #expect(invocation.workingDirectory == "/work/1")
    }

    @Test func shellScriptsRunThroughInterpreter() {
        var configuration = Fix.configuration
        configuration.enginePath = "/tools/build.sh"
        let invocation = EngineInvocationBuilder.invocation(
            for: BuildJob(sourcePath: Fix.source, title: Fix.title), configuration: configuration, workDirectory: "/w"
        )
        #expect(invocation.executable == "/bin/sh")
        #expect(invocation.arguments.first == "/tools/build.sh")
    }

    @Test func lineSplitterHandlesPartialsAndCRLF() {
        var splitter = LineSplitter()
        #expect(splitter.append(Data("one\r\ntw".utf8)) == ["one"])
        #expect(splitter.append(Data("o\nthree".utf8)) == ["two"])
        #expect(splitter.flush() == "three")
        #expect(splitter.flush() == nil)
    }
}
