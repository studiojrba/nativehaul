import Foundation
@testable import NXShelf
import Testing

struct CleanupTests {
    typealias Fix = NXNativeFixtures
    private let work = "/work/job"

    private func makeWork(_ files: InMemoryFileOperations, extra: [String] = []) {
        files.addFile("\(work)/output.app/Contents/MacOS/game", executable: true)
        files.addFile("\(work)/.nxnative-lib/lib.dylib")
        files.addFile("\(work)/temp.bin")
        files.addDirectory("\(work)/extracted")
        extra.forEach { files.addFile("\(work)/\($0)") }
    }

    @Test func plansKeepRenameAndTrash() {
        let files = Fix.files()
        makeWork(files)
        let plan = CleanupPlanner(files: files).plan(
            workDirectory: work,
            titleName: "Tideborn",
            titleID: Fix.title.titleID,
            configuration: Fix.configuration
        )
        #expect(plan.actions == [
            .moveApp(from: "\(work)/output.app", to: "/games/Tideborn.app"),
            .moveLibrary(from: "\(work)/.nxnative-lib", to: "/games/.nxnative-lib"),
            .moveToTrash("\(work)/extracted"),
            .moveToTrash("\(work)/temp.bin"),
            .moveToTrash(work),
        ])
    }

    @Test func neverOverwritesExistingApp() {
        let files = Fix.files()
        makeWork(files)
        files.addDirectory("/games/Tideborn.app")
        let plan = CleanupPlanner(files: files).plan(
            workDirectory: work,
            titleName: "Tideborn",
            titleID: "X",
            configuration: Fix.configuration
        )
        #expect(plan.finalAppPath == "/games/Tideborn (2).app")
    }

    @Test func existingLibraryIsLeftForReviewAndWorkDirKept() {
        let files = Fix.files()
        makeWork(files)
        files.addDirectory("/games/.nxnative-lib")
        let plan = CleanupPlanner(files: files).plan(
            workDirectory: work,
            titleName: "Tideborn",
            titleID: "X",
            configuration: Fix.configuration
        )
        #expect(plan.actions.contains(.leave(
            "\(work)/.nxnative-lib",
            reason: "a library folder already exists in the output folder"
        )))
        #expect(!plan.actions.contains(.moveToTrash(work)))
    }

    @Test func ambiguousOutputIsLeftAlone() {
        let files = Fix.files()
        files.addDirectory("\(work)/a.app")
        files.addDirectory("\(work)/b.app")
        let plan = CleanupPlanner(files: files).plan(
            workDirectory: work,
            titleName: "T",
            titleID: "X",
            configuration: Fix.configuration
        )
        #expect(plan.finalAppPath == nil)
        #expect(plan.actions.allSatisfy {
            if case .leave = $0 {
                true
            } else {
                false
            }
        })
    }

    @Test func sanitizesTitle() {
        #expect(CleanupPlanner.sanitizedName("Moon/Well: Deluxe.", fallback: "ID") == "Moon-Well - Deluxe")
        #expect(CleanupPlanner.sanitizedName("  ", fallback: "0100") == "0100")
    }

    @Test func executorMovesAndTrashesWithAudit() throws {
        let files = Fix.files()
        makeWork(files)
        let audit = InMemoryAuditLog()
        let plan = CleanupPlanner(files: files).plan(
            workDirectory: work,
            titleName: "Tideborn",
            titleID: "X",
            configuration: Fix.configuration
        )
        try CleanupExecutor(files: files, audit: audit).execute(plan)
        #expect(files.fileExists(atPath: "/games/Tideborn.app/Contents/MacOS/game"))
        #expect(files.fileExists(atPath: "/games/.nxnative-lib/lib.dylib"))
        #expect(files.trashedPaths == ["\(work)/extracted", "\(work)/temp.bin", work])
        #expect(try audit.entries().count == plan.actions.count)
    }
}
