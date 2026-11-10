@testable import NXShelf
import Testing

struct TitleNormalizerTests {
    @Test func ignoresCaseDiacriticsAndPunctuation() {
        #expect(TitleNormalizer.matches("Pokémon™: Let's Go!", "pokemon lets go"))
        #expect(TitleNormalizer.key(for: "Hollow Knight: Silksong") == "hollowknightsilksong")
    }

    @Test func emptyKeysNeverMatch() {
        #expect(!TitleNormalizer.matches("!!!", "???"))
        #expect(!TitleNormalizer.matches("Tideborn", "Moonwell"))
    }
}
