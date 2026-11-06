import Foundation

/// Errors from the HLTB layer.
enum HLTBError: Error, Equatable, LocalizedError {
    /// No official HowLongToBeat API is available, so automatic lookup is disabled.
    case remoteUnavailable
    /// The estimates file exists but isn't a list of estimates.
    case cacheUnreadable(String)

    /// User-facing description.
    var errorDescription: String? {
        switch self {
        case .remoteUnavailable:
            "HowLongToBeat has no official API, so Playrite doesn't fetch automatically. "
                + "Look it up and enter the figures."
        case let .cacheUnreadable(reason):
            "The HLTB estimates file couldn't be read (\(reason)). It was left as it is."
        }
    }
}
