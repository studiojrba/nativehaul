import Foundation

/// Decodes one cache entry without failing the whole file: an unreadable entry becomes `nil` and is counted.
struct LossyHLTBEstimate: Decodable {
    /// The entry, when readable.
    let estimate: HLTBEstimate?

    init(from decoder: any Decoder) throws {
        estimate = try? HLTBEstimate(from: decoder)
    }
}
