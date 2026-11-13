import Foundation

/// One hero carousel slide: a game and its generated copy.
struct HeroSlide: Identifiable {
    /// The game.
    let game: Game
    /// Its words.
    let copy: HeroCopy

    /// The game's identity.
    var id: UUID {
        game.id
    }
}
