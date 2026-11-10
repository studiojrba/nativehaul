import Foundation
@testable import NXShelf
import Testing

@MainActor
struct MetadataMergeTests {
    @Test func mergeKeepsManualArtProtectionAndCarousel() {
        let survivor = Game(title: "Tideborn", summary: "Imported.")
        let duplicate = Game(title: "Tideborn")
        duplicate.coverImagePath = "/Users/jr/cover.png"
        duplicate.carouselImagePaths = ["/cache/a.jpg"]
        duplicate.summary = "Fetched."
        duplicate.metadataProvenance = MetadataProvenance([
            .cover: .user,
            .carousel: .titleDB,
            .description: .titleDB,
        ])
        GameMerger.merge(duplicate, into: survivor)
        #expect(survivor.coverImagePath == "/Users/jr/cover.png")
        #expect(survivor.metadataProvenance[.cover] == .user)
        #expect(survivor.carouselImagePaths == ["/cache/a.jpg"])
        #expect(survivor.summary == "Imported.")
        #expect(survivor.metadataProvenance[.description] == nil)
    }
}
