import Foundation

/// Transport-level errors raised by ``HTTPClient`` implementations.
enum HTTPClientError: Error, Equatable {
    /// The response was not an HTTP response.
    case nonHTTPResponse
    /// A mock had no stub for the requested URL path.
    case noStub(String)
}
