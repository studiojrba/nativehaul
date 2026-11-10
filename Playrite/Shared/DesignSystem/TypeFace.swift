import AppKit
import CoreText
import SwiftUI
import Synchronization

/// The one type family everything is set in (ADR 0041): a neutral grotesque, never a rounded or monospaced variant.
/// Display, labels, buttons and figures all come from here; figures use tabular numbers instead of a mono face.
enum TypeFace {
    /// Inter's family name as registered from the bundled variable font.
    static let interName = "Inter Variable"
    /// Headline tracking, as a share of the size (tighter than the default; big type reads tighter).
    static let headlineTrackingEm: CGFloat = -0.03
    private static let interResource = "InterVariable"
    private static let selected = Mutex(TypeFamily.inter)

    /// The family in use. Inter until J.R locks his pick; falls back to SF Pro if Inter can't be loaded.
    static var family: TypeFamily {
        get { selected.withLock { $0 } }
        set { selected.withLock { $0 = newValue } }
    }

    /// Registers the bundled Inter font for this process (called once at launch).
    static func registerBundledFonts() {
        guard let url = Bundle.main.url(forResource: interResource, withExtension: "ttf") else { return }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }

    /// Whether Inter is available.
    static var isInterAvailable: Bool {
        NSFont(name: interName, size: NSFont.systemFontSize) != nil
    }

    /// A font of `size` and `weight` in the current family.
    static func font(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        if family == .inter, isInterAvailable {
            return Font.custom(interName, fixedSize: size).weight(weight)
        }
        return Font.system(size: size, weight: weight, design: .default)
    }

    /// A tabular-figures font (numbers line up in columns) in the current family.
    static func figures(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        font(size: size, weight: weight).monospacedDigit()
    }

    /// The AppKit equivalent (for drawn textures such as the game case's spine).
    static func nsFont(size: CGFloat, weight: NSFont.Weight) -> NSFont {
        let system = NSFont.systemFont(ofSize: size, weight: weight)
        guard family == .inter, let inter = NSFont(name: interName, size: size) else { return system }
        let descriptor = inter.fontDescriptor.addingAttributes([
            .traits: [NSFontDescriptor.TraitKey.weight: weight],
        ])
        return NSFont(descriptor: descriptor, size: size) ?? inter
    }

    /// Headline tracking for type of `size`.
    static func headlineTracking(for size: CGFloat) -> CGFloat {
        size * headlineTrackingEm
    }
}
