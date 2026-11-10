import Foundation

extension ThrottlePolicy {
    private static let steamGridDBMilliseconds = 500
    private static let imageMilliseconds = 250
    /// IGDB allows four requests a second.
    private static let igdbMilliseconds = 300
    private static let igdbSpacing = Duration.milliseconds(igdbMilliseconds)
    private static let steamGridDBSpacing = Duration.milliseconds(steamGridDBMilliseconds)
    private static let imageSpacing = Duration.milliseconds(imageMilliseconds)

    /// Spacing for metadata traffic: each API keeps to its published rate, and image downloads are spaced lightly.
    static let metadata = ThrottlePolicy(
        defaultInterval: imageSpacing,
        hostIntervals: [
            "www.steamgriddb.com": steamGridDBSpacing,
            "api.igdb.com": igdbSpacing,
        ]
    )
}
