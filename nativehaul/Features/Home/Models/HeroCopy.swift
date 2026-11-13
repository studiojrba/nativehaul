import Foundation

/// The words on one hero slide (spec §3.1): eyebrow, the "{lead} *{emphasis}*{trailing}" headline and the progress
/// line. Generated from real data by ``HeroCopyWriter``; never hand-written per game.
struct HeroCopy: Equatable, Sendable {
    /// The small uppercase line above the headline.
    let eyebrow: String
    /// The headline's plain lead.
    let lead: String
    /// The headline's emphasised phrase (italic, `ink-soft`).
    let emphasis: String
    /// Punctuation after the emphasis ("." or "?").
    let trailing: String
    /// The progress line under the headline.
    let progress: String

    /// The headline as one plain string (accessibility, tests).
    var headline: String {
        "\(lead) \(emphasis)\(trailing)"
    }
}
