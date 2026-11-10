import Foundation
@testable import nativehaul
import Testing

/// ADR 0038: joining a port's Switch title ID to titledb's NSUID-keyed region records.
struct TitleDBIndexTests {
    private static let botwID = "01007EF00011E000"
    private static let wonderID = "010015100B514000"

    private static let regionFile = """
    {
      "70010000000025": {"id": "01007EF00011E000", "nsuId": 70010000000025,
        "name": "The Legend of Zelda™: Breath of the Wild", "description": "Forget everything.\\n",
        "screenshots": ["https://img.example/b1.jpg", "https://img.example/b2.jpg"],
        "bannerUrl": "https://img.example/botw-banner.jpg", "isDemo": false, "rating": 10},
      "70010000096817": {"id": "01007EF00011E000", "nsuId": 70010000096817,
        "name": "The Legend of Zelda™: Breath of the Wild – Nintendo Switch™ 2 Edition",
        "description": "Upgraded.", "screenshots": [], "bannerUrl": null, "isDemo": false},
      "70010000068688": {"id": "010015100B514000", "nsuId": 70010000068688, "name": "Super Mario Bros.™ Wonder",
        "description": "Wonder.", "screenshots": ["https://img.example/w1.jpg"], "bannerUrl": null, "isDemo": false},
      "70010000115567": {"id": "010015100B514000", "nsuId": 70010000115567,
        "name": "Super Mario Bros.™ Wonder – Nintendo Switch™ 2 Edition + Meetup in Bellabel Park",
        "description": "Bundle.", "screenshots": ["https://img.example/m1.jpg"], "bannerUrl": null, "isDemo": false},
      "70010000094264": {"id": null, "nsuId": 70010000094264, "name": "Tideborn Chronicles",
        "description": "Only by name.", "screenshots": [], "bannerUrl": null, "isDemo": false},
      "70030000012254": {"id": "0100AAAA00000000", "nsuId": 70030000012254, "name": "Tideborn Demo",
        "description": "Demo.", "screenshots": [], "bannerUrl": null, "isDemo": true}
    }
    """

    private func index() throws -> TitleDBIndex {
        try TitleDBIndex.build(regionFile: Data(Self.regionFile.utf8), region: "US.en", fetchedAt: .distantPast)
    }

    @Test func aTitleIDFindsItsOwnListingNotTheSwitch2Edition() throws {
        let entry = try #require(try index().resolve(titleID: Self.botwID.lowercased(), title: "Zelda BOTW port"))
        #expect(entry.nsuID == 70_010_000_000_025)
        #expect(entry.screenshots.count == 2)
    }

    @Test func theLibraryTitleBreaksATieBetweenListings() throws {
        let entry = try #require(try index().resolve(titleID: Self.wonderID, title: "Super Mario Bros. Wonder"))
        #expect(entry.nsuID == 70_010_000_068_688)
    }

    @Test func withoutANameMatchTheLowestNSUIDWinsAmongEqualScreenshots() throws {
        let entry = try #require(try index().resolve(titleID: Self.wonderID, title: "Wonder (port)"))
        #expect(entry.nsuID == 70_010_000_068_688)
    }

    @Test func anUpdateIDResolvesThroughItsBaseApplication() throws {
        let entry = try #require(try index().resolve(titleID: "01007EF00011E800", title: "Something else"))
        #expect(entry.nsuID == 70_010_000_000_025)
        #expect(SwitchTitleID("0100000000011001")?.baseID.hex == "0100000000010000")
    }

    @Test func aListingWithoutATitleIDMatchesOnlyByExactTitle() throws {
        let index = try index()
        #expect(index.resolve(titleID: "0100BBBB00000000", title: "Tideborn Chronicles")?.nsuID == 70_010_000_094_264)
        #expect(index.resolve(titleID: "0100BBBB00000000", title: "Tideborn") == nil)
    }

    @Test func demosAreNeverKept() throws {
        #expect(try index().entries.contains { $0.name.contains("Demo") } == false)
    }

    @Test func malformedTitleIDsAreRejected() {
        #expect(SwitchTitleID("not-an-id") == nil)
        #expect(NXNativeAppTitleID.titleID(fromBundleIdentifier: "org.nxnative.0100f2c0115b6000") == "0100F2C0115B6000")
        #expect(NXNativeAppTitleID.titleID(fromBundleIdentifier: "com.studiojrba.nativehaul") == nil)
    }

    @Test func theCompactIndexRoundTrips() throws {
        let index = try index()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let copy = try decoder.decode(TitleDBIndex.self, from: encoder.encode(index))
        #expect(copy.entries == index.entries)
        #expect(copy.resolve(titleID: Self.botwID, title: "")?.nsuID == 70_010_000_000_025)
    }
}
