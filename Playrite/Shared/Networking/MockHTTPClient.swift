import Foundation

/// Mock ``HTTPClient`` returning stubbed bodies keyed by URL path. Records requested URLs.
actor MockHTTPClient: HTTPClient {
    /// A stubbed response.
    struct Stub: Sendable {
        /// Response body.
        let body: Data
        /// HTTP status code.
        let statusCode: Int
    }

    private static let okStatus = 200
    private var stubs: [String: Stub] = [:]
    /// URLs requested so far, in order.
    private(set) var requestedURLs: [URL] = []

    /// Creates an empty mock.
    init() {}

    /// Stubs a response for any URL whose path contains `pathFragment`.
    func stub(pathContaining pathFragment: String, json: String, statusCode: Int = okStatus) {
        stubs[pathFragment] = Stub(body: Data(json.utf8), statusCode: statusCode)
    }

    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        guard let url = request.url else { throw HTTPClientError.nonHTTPResponse }
        requestedURLs.append(url)
        guard let stub = stubs.first(where: { url.path.contains($0.key) })?.value else {
            throw HTTPClientError.noStub(url.path)
        }
        guard let response = HTTPURLResponse(url: url, statusCode: stub.statusCode, httpVersion: nil, headerFields: nil)
        else { throw HTTPClientError.nonHTTPResponse }
        return (stub.body, response)
    }
}
