import Foundation

/// Mock ``HTTPClient`` returning stubbed bodies keyed by URL path or by a fragment of the full URL.
/// Records every request.
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
    private var urlStubs: [String: Stub] = [:]
    /// URLs requested so far, in order.
    private(set) var requestedURLs: [URL] = []
    /// Requests made so far, in order (for header checks).
    private(set) var requests: [URLRequest] = []

    /// Creates an empty mock.
    init() {}

    /// Stubs a response for any URL whose path contains `pathFragment`.
    func stub(pathContaining pathFragment: String, json: String, statusCode: Int = okStatus) {
        stubs[pathFragment] = Stub(body: Data(json.utf8), statusCode: statusCode)
    }

    /// Stubs a response for any URL whose absolute string contains `fragment`. The longest matching fragment wins,
    /// and URL stubs are checked before path stubs.
    func stub(urlContaining fragment: String, data: Data, statusCode: Int = okStatus) {
        urlStubs[fragment] = Stub(body: data, statusCode: statusCode)
    }

    /// Stubs a JSON response for any URL whose absolute string contains `fragment`.
    func stub(urlContaining fragment: String, json: String, statusCode: Int = okStatus) {
        stub(urlContaining: fragment, data: Data(json.utf8), statusCode: statusCode)
    }

    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        guard let url = request.url else { throw HTTPClientError.nonHTTPResponse }
        requestedURLs.append(url)
        requests.append(request)
        let urlMatch = urlStubs.filter { url.absoluteString.contains($0.key) }.max { $0.key.count < $1.key.count }
        guard let stub = urlMatch?.value ?? stubs.first(where: { url.path.contains($0.key) })?.value else {
            throw HTTPClientError.noStub(url.absoluteString)
        }
        guard let response = HTTPURLResponse(url: url, statusCode: stub.statusCode, httpVersion: nil, headerFields: nil)
        else { throw HTTPClientError.nonHTTPResponse }
        return (stub.body, response)
    }
}
