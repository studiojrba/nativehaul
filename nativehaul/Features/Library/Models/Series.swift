import Foundation
import SwiftData

/// A franchise or series with a recommended play order.
@Model
final class Series {
    /// Stable identifier.
    @Attribute(.unique) var id: UUID
    /// Series name.
    var name: String
    /// Raw storage for ``orderBasis``.
    var orderBasisRaw: String
    /// Why this order is recommended (free text, optional).
    var notes: String
    /// Entries; use ``orderedEntries`` for the recommended order.
    @Relationship(deleteRule: .cascade, inverse: \SeriesEntry.series) var entries: [SeriesEntry] = []

    /// Creates a series.
    init(id: UUID = UUID(), name: String, orderBasis: SeriesOrderBasis = .release, notes: String = "") {
        self.id = id
        self.name = name
        orderBasisRaw = orderBasis.rawValue
        self.notes = notes
    }

    /// Typed order basis.
    var orderBasis: SeriesOrderBasis {
        get { SeriesOrderBasis(rawValue: orderBasisRaw) ?? .release }
        set { orderBasisRaw = newValue.rawValue }
    }

    /// Entries sorted by recommended position.
    var orderedEntries: [SeriesEntry] {
        entries.sorted { $0.position < $1.position }
    }
}
