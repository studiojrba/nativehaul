import Foundation

/// Remembers which bottle is the golden bottle. Live: ``UserDefaultsGoldenBottleStore``; mock:
/// ``InMemoryGoldenBottleStore``.
@MainActor
protocol GoldenBottleStoring: AnyObject {
    /// The golden bottle's name, if one was adopted or created.
    var bottleName: String? { get set }
}
