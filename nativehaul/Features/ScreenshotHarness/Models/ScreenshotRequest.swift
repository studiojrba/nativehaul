#if DEBUG
    import Foundation

    /// A DEBUG-only screenshot request (note 9), read from launch arguments:
    /// `-NHScreen onboarding.<beat>|home|library|builds|detail|settings`, `-NHAppearance dark|light` and
    /// `-NHWindow 1440x900`
    /// (`-NHScrollEnd YES` scrolls Home to its shelves). The app then opens that screen over an in-memory demo library
    /// and never touches the
    /// user's own store, folders or settings. Release builds don't contain it.
    struct ScreenshotRequest: Equatable, Sendable {
        /// Which screen.
        enum Screen: Equatable, Sendable {
            /// An onboarding beat.
            case onboarding(OnboardingBeat)
            /// Home.
            case home
            /// Library.
            case library
            /// Builds.
            case builds
            /// Detail of the game being built.
            case detail
            /// Settings.
            case settings
        }

        /// The screen.
        let screen: Screen
        /// Forced appearance, if any.
        let appearance: AppearancePreference?
        /// Window size, if given.
        let windowSize: CGSize?
        /// Scroll long pages to their end (`-NHScrollEnd YES`), to show Home's shelves.
        let scrollsToEnd: Bool

        /// The request in this process's launch arguments, if any.
        static let current: ScreenshotRequest? = ScreenshotRequest(defaults: .standard)

        /// Reads a request from `defaults` (launch arguments land in its argument domain).
        init?(defaults: UserDefaults) {
            guard let raw = defaults.string(forKey: "NHScreen"), let screen = Self.screen(raw) else { return nil }
            self.screen = screen
            appearance = defaults.string(forKey: "NHAppearance").flatMap(AppearancePreference.init(rawValue:))
            windowSize = defaults.string(forKey: "NHWindow").flatMap(Self.size)
            scrollsToEnd = defaults.bool(forKey: "NHScrollEnd")
        }

        private static func screen(_ raw: String) -> Screen? {
            let parts = raw.split(separator: ".", maxSplits: 1).map(String.init)
            switch parts.first {
            case "onboarding":
                let beat = parts.count > 1 ? OnboardingBeat(rawValue: parts[1]) : .welcome
                return beat.map(Screen.onboarding)
            case "home": return .home
            case "library": return .library
            case "builds": return .builds
            case "detail": return .detail
            case "settings": return .settings
            default: return nil
            }
        }

        /// `WIDTHxHEIGHT`.
        private static let dimensions = 2

        private static func size(_ raw: String) -> CGSize? {
            let parts = raw.split(separator: "x").compactMap { Double($0) }
            guard let width = parts.first, let height = parts.last, parts.count == Self.dimensions else { return nil }
            return CGSize(width: width, height: height)
        }
    }
#endif
