import Foundation

/// The onboarding chat's typing effect and scrolling (spec §4.4). Hard requirements: every shortcut glitches.
enum TypingTiming {
    /// The first message of a beat starts after this delay (seconds).
    static let firstDelay: Double = 0.45
    /// Typing-dots phase: base length…
    static let dotsBase: Double = 0.52
    /// …plus this per character…
    static let dotsPerCharacter: Double = 0.006
    /// …capped at this extra.
    static let dotsExtraCap: Double = 0.5
    /// One character revealed every 16ms.
    static let characterInterval: Double = 0.016
    /// Pause after `.` or `?`.
    static let sentencePause: Double = 0.14
    /// Pause after `,`.
    static let commaPause: Double = 0.08
    /// Gap after a message sends before the next begins.
    static let betweenMessages: Double = 0.26
    /// The final action finishes after this pause.
    static let finishPause: Double = 0.7

    /// Typing dot diameter.
    static let dotSize: CGFloat = 6
    /// Typing dot opacity of `ink`.
    static let dotOpacity: Double = 0.40
    /// Stagger between the three dots' bounces.
    static let dotStagger: Double = 0.12

    /// Caret width.
    static let caretWidth: CGFloat = 2
    /// Caret height, as a share of the line height.
    static let caretHeightShare: CGFloat = 0.64
    /// Caret drop from the line top, as a share of the line height.
    static let caretDropShare: CGFloat = 0.18
    /// Caret blink period (`steps(2)`).
    static let caretBlink: Double = 1

    /// Following resumes within this distance of the bottom.
    static let followThreshold: CGFloat = 64
    /// Own smooth-scroll events are ignored for this long.
    static let selfScrollIgnore: Double = 0.9

    /// How long the typing dots show for a message of `length` characters.
    static func dotsDuration(length: Int) -> Double {
        dotsBase + min(dotsExtraCap, Double(length) * dotsPerCharacter)
    }

    /// The pause after revealing `character`.
    static func delay(after character: Character) -> Double {
        switch character {
        case ".", "?": characterInterval + sentencePause
        case ",": characterInterval + commaPause
        default: characterInterval
        }
    }
}
