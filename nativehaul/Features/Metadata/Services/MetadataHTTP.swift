import Foundation

/// Shared request/decoding helper for metadata providers.
struct MetadataHTTP: Sendable {
    private static let okLowerBound = 200
    private static let okUpperBound = 300
    private static let success = okLowerBound ..< okUpperBound
    private static let notFound = 404
    private static let unauthorizedCode = 401
    private static let forbiddenCode = 403
    private static let unauthorized: Set<Int> = [unauthorizedCode, forbiddenCode]
    private let client: any HTTPClient

    /// Creates the helper.
    init(client: any HTTPClient) {
        self.client = client
    }

    /// Decodes a JSON response, or returns `nil` for 404 (the store has no such item).
    func decodeIfFound<Response: Decodable>(_ request: URLRequest) async throws -> Response? {
        let (data, response) = try await client.data(for: request)
        if response.statusCode == Self.notFound {
            return nil
        }
        if Self.unauthorized.contains(response.statusCode) {
            throw MetadataError.invalidAPIKey
        }
        guard Self.success.contains(response.statusCode) else {
            throw MetadataError.http(status: response.statusCode)
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw MetadataError.decoding
        }
    }

    /// Decodes a JSON GET.
    func get<Response: Decodable>(_ url: URL?, headers: [String: String] = [:]) async throws -> Response? {
        guard let url else { throw MetadataError.badURL }
        var request = URLRequest(url: url)
        for (name, value) in headers {
            request.setValue(value, forHTTPHeaderField: name)
        }
        return try await decodeIfFound(request)
    }
}
