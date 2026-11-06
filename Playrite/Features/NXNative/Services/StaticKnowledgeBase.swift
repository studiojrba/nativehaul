import Foundation

/// Mock ``KnowledgeBaseProviding`` with fixed cases.
struct StaticKnowledgeBase: KnowledgeBaseProviding {
    /// Cases to return.
    let entries: [TroubleshootingCase]

    func cases() -> [TroubleshootingCase] {
        entries
    }
}
