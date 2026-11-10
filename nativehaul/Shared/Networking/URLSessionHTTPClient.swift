import Foundation

/// Live ``HTTPClient`` backed by `URLSession`. Never logs request URLs (they may carry API keys).
struct URLSessionHTTPClient: HTTPClient {
    private let session: URLSession

    /// Creates a client over the given session.
    init(session: URLSession = .shared) {
        self.session = session
    }

    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPClientError.nonHTTPResponse
        }
        return (data, httpResponse)
    }
}
