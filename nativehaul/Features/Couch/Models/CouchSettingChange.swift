import Foundation

/// What a press does to a couch Settings row.
enum CouchSettingChange: Equatable, Sendable {
    /// A: toggle or run.
    case activate
    /// Left on an adjustable row.
    case decrease
    /// Right on an adjustable row.
    case increase
}
