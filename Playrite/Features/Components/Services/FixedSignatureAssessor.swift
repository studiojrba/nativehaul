import Foundation

/// Mock ``SignatureAssessing`` returning a fixed status.
struct FixedSignatureAssessor: SignatureAssessing {
    /// Status to report.
    let status: SignatureStatus

    func assess(appAt _: String) async -> SignatureStatus {
        status
    }
}
