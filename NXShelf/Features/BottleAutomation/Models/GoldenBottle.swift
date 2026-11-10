import Foundation

/// The golden bottle: one bottle whose Steam is signed in, used only as a template. Each game gets a clone of it, so
/// the user signs in to Steam once in total. No game is ever installed into the golden bottle itself.
enum GoldenBottle {
    /// Name of the bottle NX Shelf creates when it can't adopt one.
    /// Legacy identifier (ADR 0043): it names the bottle already created on disk, so it keeps the old app name.
    static let dedicatedName = "NX Shelf Steam"
    /// Windows version of a dedicated golden bottle (recipes asking for another version set it after cloning).
    static let template = BottleTemplate.win10
}
