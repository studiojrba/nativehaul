import SwiftUI

extension EnvironmentValues {
    /// The token set for this view's appearance (follows `colorScheme`). Most views use ``Theme`` colours instead;
    /// this is for maths on raw values.
    var themeTokens: ThemeTokens {
        ThemeTokens.resolved(for: colorScheme)
    }

    /// Per-game tones for this view's appearance (follows `colorScheme`).
    var gameTones: GameTones {
        GameTones(scheme: colorScheme)
    }
}
