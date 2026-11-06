import Foundation

/// Why the loopback listener stopped without a callback.
enum LoopbackCallbackError: Error, Equatable {
    /// The listener couldn't open a port on 127.0.0.1.
    case couldNotListen
    /// No callback arrived in time (for example, the user closed the browser tab).
    case timedOut
    /// The wait was cancelled.
    case cancelled
}
