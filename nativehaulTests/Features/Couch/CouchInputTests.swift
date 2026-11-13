import Foundation
@testable import nativehaul
import Testing

/// Spec §3.7: stick threshold 0.6, repeats at 280ms then every 110ms, the development keys, the clock and the letters.
struct CouchInputTests {
    @Test func theStickCountsPastPointSixOnItsDominantAxis() {
        #expect(StickDirection.direction(x: 0.59, y: 0) == nil)
        #expect(StickDirection.direction(x: 0.61, y: 0) == .right)
        #expect(StickDirection.direction(x: -0.9, y: 0.3) == .left)
        #expect(StickDirection.direction(x: 0.2, y: 0.8) == .up)
        #expect(StickDirection.direction(x: 0.1, y: -0.7) == .down)
        #expect(CouchInputTiming.stickThreshold == 0.6)
    }

    @Test func heldDirectionsRepeatAfter280msThenEvery110ms() {
        #expect(CouchInputTiming.fireTime(ofRepeat: 0) == 0)
        #expect(abs(CouchInputTiming.fireTime(ofRepeat: 1) - 0.28) < 1e-9)
        #expect(abs(CouchInputTiming.fireTime(ofRepeat: 2) - 0.39) < 1e-9)
        #expect(abs(CouchInputTiming.fireTime(ofRepeat: 4) - 0.61) < 1e-9)
        #expect(CouchInputTiming.toastDuration == 1.1)
    }

    @Test func developmentKeysMapToTheController() {
        #expect(CouchKeyboardMap.input(for: .arrow(.left)) == .move(.left))
        #expect(CouchKeyboardMap.input(for: .returnKey) == .select)
        #expect(CouchKeyboardMap.input(for: .escape) == .back)
        #expect(CouchKeyboardMap.input(for: .character("q")) == .previousGame)
        #expect(CouchKeyboardMap.input(for: .character("E")) == .nextGame)
        #expect(CouchKeyboardMap.input(for: .character("z")) == .previousLetter)
        #expect(CouchKeyboardMap.input(for: .character("c")) == .nextLetter)
        #expect(CouchKeyboardMap.input(for: .character("h")) == .home)
        #expect(CouchKeyboardMap.input(for: .character("m")) == .view)
        #expect(CouchKeyboardMap.input(for: .character("k")) == nil)
    }

    @Test func theClockReadsHourAndMinutes() throws {
        let zone = try #require(TimeZone(identifier: "America/New_York"))
        var components = DateComponents()
        components.year = 2026
        components.month = 11
        components.day = 13
        components.hour = 21
        components.minute = 5
        components.timeZone = zone
        let date = try #require(Calendar(identifier: .gregorian).date(from: components))
        #expect(CouchClock.string(from: date, timeZone: zone) == "9:05")
    }

    @Test func lettersIgnoreTheFoldAccentsAndGroupTheRest() {
        #expect(LetterJump.initial(of: "The Banner Saga") == "B")
        #expect(LetterJump.initial(of: "Élan") == "E")
        #expect(LetterJump.initial(of: "007 Legends") == "#")
        #expect(LetterJump.initial(of: "") == "#")
    }

    @Test func letterJumpsLandOnGroupStarts() {
        let titles = ["Animal", "Astro", "Bayonetta", "Celeste", "Cuphead", "Élan"]
        #expect(LetterJump.next(from: 0, titles: titles) == 2)
        #expect(LetterJump.next(from: 3, titles: titles) == 5)
        #expect(LetterJump.next(from: 5, titles: titles) == 5)
        #expect(LetterJump.previous(from: 4, titles: titles) == 3)
        #expect(LetterJump.previous(from: 3, titles: titles) == 2)
        #expect(LetterJump.previous(from: 1, titles: titles) == 0)
        #expect(LetterJump.previous(from: 0, titles: titles) == 0)
    }

    @Test func couchScaleKeeps1080pAnd4KAlike() {
        let hd = CouchScale(size: CGSize(width: 1920, height: 1080))
        let uhd = CouchScale(size: CGSize(width: 3840, height: 2160))
        #expect(hd.visibleTiles == 6)
        #expect(uhd.visibleTiles == 6)
        #expect(uhd(CouchLayout.Shelves.tileWidth) == 2 * hd(CouchLayout.Shelves.tileWidth))
        #expect(CouchScale(size: CGSize(width: 1100, height: 700)).visibleTiles >= 1)
    }
}
