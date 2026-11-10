import SwiftUI

/// Carries the current screen's art path up to the shell.
struct SceneTintArtKey: PreferenceKey {
    static let defaultValue: String? = nil

    static func reduce(value: inout String?, nextValue: () -> String?) {
        value = value ?? nextValue()
    }
}

extension View {
    /// Tints the whole scene in a pastel of the art at `path` (no tint when `nil`).
    func sceneTint(fromArtAt path: String?) -> some View {
        preference(key: SceneTintArtKey.self, value: path)
    }
}
