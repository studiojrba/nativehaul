import Foundation

extension ThrottlePolicy {
    private static let steamStoreMilliseconds = 1500
    private static let steamGridDBMilliseconds = 500
    private static let imageMilliseconds = 250
    /// IGDB allows four requests a second.
    private static let igdbMilliseconds = 300
    private static let igdbSpacing = Duration.milliseconds(igdbMilliseconds)
    private static let steamStoreSpacing = Duration.milliseconds(steamStoreMilliseconds)
    private static let steamGridDBSpacing = Duration.milliseconds(steamGridDBMilliseconds)
    private static let imageSpacing = Duration.milliseconds(imageMilliseconds)

    /// Spacing for metadata traffic: the Steam store `appdetails` endpoint is rate-limited (roughly 200 calls per
    /// five minutes), so it gets the widest gap.
    static let metadata = ThrottlePolicy(
        defaultInterval: imageSpacing,
        hostIntervals: [
            "store.steampowered.com": steamStoreSpacing,
            "www.steamgriddb.com": steamGridDBSpacing,
            "api.igdb.com": igdbSpacing,
        ]
    )
}
