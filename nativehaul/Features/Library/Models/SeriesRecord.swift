import Foundation

/// Archive form of a ``Series``.
struct SeriesRecord: Codable, Equatable, Sendable {
    var id: UUID
    var name: String
    var orderBasis: SeriesOrderBasis
    var notes: String
    var entries: [SeriesEntryRecord]
}
