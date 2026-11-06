import Foundation

/// One entry of the Steam store `appdetails` response (`{"<appid>": {"success": …, "data": …}}`).
struct SteamStoreAppDetailsEnvelope: Decodable, Sendable {
    /// Whether Steam found the app.
    let success: Bool
    /// The app's store data.
    let data: SteamStoreAppDetails?
}
