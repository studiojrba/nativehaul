import Foundation

extension NXNativeViewModel {
    /// All documented troubleshooting cases.
    var knowledgeBase: [TroubleshootingCase] {
        services.knowledgeBase.cases()
    }

    /// Cases suggested by a job's log.
    func suggestedCases(for job: BuildJob) -> [TroubleshootingCase] {
        services.knowledgeBase.cases(matching: job.log)
    }
}
