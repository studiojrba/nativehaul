import Foundation

extension Game {
    /// The emulated system, for ``GamePlatform/emulated`` entries.
    var emulatedSystem: EmulatedSystem? {
        get { emulatedSystemRaw.flatMap(EmulatedSystem.init(rawValue:)) }
        set { emulatedSystemRaw = newValue?.rawValue }
    }
}
