import Foundation

/// Minimal HTTP abstraction so services can be tested without the network.
protocol HTTPClient: Sendable {
    /// Performs a request and returns the body with its HTTP response.
    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse)
}
