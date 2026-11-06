import Foundation

/// The request line of an HTTP request received on the loopback listener.
struct LoopbackHTTPRequest: Equatable, Sendable {
    private static let requestLineParts = 3
    private static let methodIndex = 0
    private static let targetIndex = 1
    private static let versionIndex = 2

    /// "GET".
    let method: String
    /// Path and query ("/steam-openid/callback?openid.mode=…").
    let target: String

    /// Parses the first line of `data`; `nil` when it isn't an HTTP request line.
    init?(_ data: Data) {
        guard let text = String(
            bytes: data.prefix(while: { $0 != UInt8(ascii: "\r") && $0 != UInt8(ascii: "\n") }),
            encoding: .utf8
        )
        else { return nil }
        let parts = text.split(separator: " ")
        guard parts.count == Self.requestLineParts, parts[Self.versionIndex].hasPrefix("HTTP/"),
              parts[Self.targetIndex].hasPrefix("/") else { return nil }
        method = String(parts[Self.methodIndex])
        target = String(parts[Self.targetIndex])
    }

    /// The path without the query.
    var path: String {
        String(target.prefix { $0 != "?" })
    }
}
