import Foundation

/// The gamepad poller's rates (spec §3.7): a direction fires on press, repeats after 280ms, then every 110ms; the
/// analogue stick counts past 0.6.
enum CouchInputTiming {
    /// First repeat of a held direction (seconds).
    static let repeatDelay = 0.28
    /// Later repeats (seconds).
    static let repeatInterval = 0.11
    /// Stick deflection that counts as a direction.
    static let stickThreshold: Float = 0.6
    /// Letter and short toasts stay this long (seconds).
    static let toastDuration = 1.1
    /// The status pill's clock refreshes this often (seconds).
    static let clockRefresh = 15.0
    /// Close game: how long a game has to quit gracefully before Force quit is offered (TV plan Q3, seconds).
    static let gracefulCloseTimeout = 10.0

    /// When the `count`-th event of a held direction fires, counted from the press (the press itself is 0).
    static func fireTime(ofRepeat count: Int) -> Double {
        guard count > 0 else { return 0 }
        return repeatDelay + Double(count - 1) * repeatInterval
    }
}
