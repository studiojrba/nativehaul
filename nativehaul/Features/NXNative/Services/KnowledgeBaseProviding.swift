import Foundation

/// Supplies troubleshooting cases. Live: ``BundledKnowledgeBase``; mock: ``StaticKnowledgeBase``.
protocol KnowledgeBaseProviding: Sendable {
    /// All documented cases.
    func cases() -> [TroubleshootingCase]
}

extension KnowledgeBaseProviding {
    /// Cases whose log signatures appear in `log` (case-insensitive).
    func cases(matching log: [BuildLogLine]) -> [TroubleshootingCase] {
        let text = log.map(\.text).joined(separator: "\n").lowercased()
        return cases().filter { entry in entry.logSignatures.contains { text.contains($0.lowercased()) } }
    }
}
