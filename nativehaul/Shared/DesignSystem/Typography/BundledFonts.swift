import CoreText
import Foundation

/// The fonts nativehaul ships (ADR 0054, SIL OFL 1.1): Geist (variable weight) for UI text and Instrument Serif for
/// display type. They are registered for this process only, at launch, before any view draws.
enum BundledFonts {
    /// The font files, as bundled resources.
    static let files = ["Geist-Variable.ttf", "InstrumentSerif-Regular.ttf", "InstrumentSerif-Italic.ttf"]
    /// Their licence texts, also bundled.
    static let licences = ["Geist-OFL.txt", "InstrumentSerif-OFL.txt"]

    /// Whether every bundled font is registered. Evaluated once (thread-safe lazy static), so any font token can
    /// read it to guarantee registration even where the app delegate never ran (SwiftUI previews).
    static let isRegistered: Bool = register()

    /// Registers the bundled fonts for this process. Already-registered fonts count as success.
    /// - Returns: `true` when every file was found and is registered.
    @discardableResult
    static func register(in bundle: Bundle = .main) -> Bool {
        files.allSatisfy { file in
            guard let url = bundle.url(forResource: file, withExtension: nil) else { return false }
            var error: Unmanaged<CFError>?
            if CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
                return true
            }
            let code = error.map { CFErrorGetCode($0.takeRetainedValue()) }
            return code == CTFontManagerError.alreadyRegistered.rawValue
        }
    }
}
