import Foundation

/// Jump by letter on LT/RT (ZL/ZR) (spec §3.7): titles compare by their first letter ignoring a leading "The";
/// accents fold ("Élan" is E) and anything that isn't a letter is "#".
enum LetterJump {
    /// The group for titles that don't start with a letter.
    static let nonLetter = "#"

    /// The initial `title` is grouped under.
    static func initial(of title: String) -> String {
        let key = LibrarySort.sortKey(for: title)
        guard let first = key.first else { return nonLetter }
        let folded = String(first).folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
        guard let letter = folded.first, letter.isLetter else { return nonLetter }
        return letter.uppercased()
    }

    /// The first tile of the next letter group after `index` (the last tile when already in the last group).
    static func next(from index: Int, titles: [String]) -> Int {
        guard titles.indices.contains(index) else { return index }
        let current = initial(of: titles[index])
        var target = index
        while target < titles.count - 1, initial(of: titles[target]) == current {
            target += 1
        }
        return target
    }

    /// The start of the current letter group, or — when already there — the start of the previous group.
    static func previous(from index: Int, titles: [String]) -> Int {
        guard titles.indices.contains(index) else { return index }
        let current = initial(of: titles[index])
        var target = index
        while target > 0, initial(of: titles[target - 1]) == current {
            target -= 1
        }
        guard target == index, target > 0 else { return target }
        target -= 1
        let previous = initial(of: titles[target])
        while target > 0, initial(of: titles[target - 1]) == previous {
            target -= 1
        }
        return target
    }
}
