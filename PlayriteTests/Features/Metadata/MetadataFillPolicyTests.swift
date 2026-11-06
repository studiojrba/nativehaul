import Foundation
@testable import Playrite
import Testing

@MainActor
struct MetadataFillPolicyTests {
    @Test func emptyFieldsAreAlwaysWritable() {
        let game = Game(title: "Blank")
        #expect(MetadataFillPolicy.writableFields(for: game, mode: .fillMissing) == Set(MetadataField.allCases))
    }

    @Test func fillMissingNeverTouchesValues() {
        let game = Game(title: "Imported", summary: "My own words.")
        game.developer = "Studio"
        #expect(!MetadataFillPolicy.canWrite(.description, for: game, mode: .fillMissing))
        #expect(!MetadataFillPolicy.canWrite(.developer, for: game, mode: .fillMissing))
    }

    @Test func refreshMayReplaceImportedText() {
        let game = Game(title: "Imported", summary: "Imported description.")
        #expect(MetadataFillPolicy.canWrite(.description, for: game, mode: .refresh))
    }

    @Test func manualArtWithoutProvenanceIsNeverReplaced() {
        let game = Game(title: "Chosen")
        game.coverImagePath = "/Users/jr/Pictures/cover.png"
        #expect(!MetadataFillPolicy.canWrite(.cover, for: game, mode: .refresh))
    }

    @Test func fetchedArtIsReplacedOnlyOnRefresh() {
        let game = Game(title: "Fetched")
        game.coverImagePath = "/cache/cover.jpg"
        game.metadataProvenance = MetadataProvenance([.cover: .steamGridDB])
        #expect(!MetadataFillPolicy.canWrite(.cover, for: game, mode: .fillMissing))
        #expect(MetadataFillPolicy.canWrite(.cover, for: game, mode: .refresh))
    }

    @Test func userSetFieldsAreNeverWritable() {
        let game = Game(title: "Mine")
        game.metadataProvenance = MetadataProvenance([.hero: .user, .description: .user])
        #expect(!MetadataFillPolicy.canWrite(.hero, for: game, mode: .refresh))
        #expect(!MetadataFillPolicy.canWrite(.description, for: game, mode: .fillMissing))
    }

    @Test func provenanceRoundTripsThroughItsStoredForm() {
        let provenance = MetadataProvenance([.cover: .user, .genres: .steamStore])
        let decoded = MetadataProvenance(rawEntries: provenance.rawEntries + ["bogus=entry", "nonsense"])
        #expect(decoded == provenance)
        #expect(provenance.rawEntries == ["genres=steamStore", "cover=user"])
    }
}
