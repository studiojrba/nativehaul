import Foundation
@testable import Playrite
import Testing

/// Exercises the real listener on 127.0.0.1 (no network leaves the machine).
@MainActor
struct LoopbackCallbackServerTests {
    private let session = URLSession(configuration: .ephemeral)

    private func get(_ port: UInt16, _ target: String) async throws -> (Int, String) {
        let url = try #require(URL(string: "http://127.0.0.1:\(port)\(target)"))
        let (data, response) = try await session.data(from: url)
        return ((response as? HTTPURLResponse)?.statusCode ?? 0, String(bytes: data, encoding: .utf8) ?? "")
    }

    @Test func requestLineParsing() {
        let request = LoopbackHTTPRequest(Data("GET /steam-openid/callback?a=1 HTTP/1.1\r\nHost: x\r\n\r\n".utf8))
        #expect(request?.method == "GET")
        #expect(request?.path == "/steam-openid/callback")
        #expect(request?.target == "/steam-openid/callback?a=1")
        #expect(LoopbackHTTPRequest(Data("garbage".utf8)) == nil)
        #expect(LoopbackHTTPRequest(Data("GET http://evil/ HTTP/1.1".utf8)) == nil)
    }

    @Test func capturesExactlyOneCallbackIgnoringStrayRequestsThenStops() async throws {
        let server = LoopbackCallbackServer(callbackPath: "/steam-openid/callback")
        let port = try await server.start()
        #expect(port > 0)
        let waiting = Task { try await server.waitForCallback(timeout: .seconds(10)) }
        let favicon = try await get(port, "/favicon.ico")
        #expect(favicon.0 == 404)
        let callback = try await get(port, "/steam-openid/callback?openid.mode=id_res&x=1")
        #expect(callback.0 == 200)
        #expect(callback.1.contains("close this tab"))
        let url = try await waiting.value
        #expect(url.absoluteString == "http://127.0.0.1:\(port)/steam-openid/callback?openid.mode=id_res&x=1")
        await #expect(throws: (any Error).self) { _ = try await get(port, "/steam-openid/callback?again=1") }
    }

    @Test func timesOutWhenTheBrowserNeverComesBack() async throws {
        let server = LoopbackCallbackServer(callbackPath: "/cb")
        let port = try await server.start()
        await #expect(throws: LoopbackCallbackError.timedOut) {
            try await server.waitForCallback(timeout: .milliseconds(50))
        }
        await #expect(throws: (any Error).self) { _ = try await get(port, "/cb") }
    }

    @Test func cancellingStopsTheListener() async throws {
        let server = LoopbackCallbackServer(callbackPath: "/cb")
        let port = try await server.start()
        let waiting = Task { try await server.waitForCallback(timeout: .seconds(10)) }
        try await Task.sleep(for: .milliseconds(20))
        waiting.cancel()
        await #expect(throws: LoopbackCallbackError.cancelled) { try await waiting.value }
        await #expect(throws: (any Error).self) { _ = try await get(port, "/cb") }
    }

    @Test func twoServersGetDifferentPorts() async throws {
        let first = LoopbackCallbackServer(callbackPath: "/cb")
        let second = LoopbackCallbackServer(callbackPath: "/cb")
        let ports = try await (first.start(), second.start())
        #expect(ports.0 != ports.1)
        first.stop()
        second.stop()
    }

    @Test func browserSignInOpensSteamWithTheListenersAddressAndReturnsTheRedirect() async throws {
        let opener = RecordingURLOpener()
        let signIn = LoopbackSteamBrowserSignIn(opener: opener, timeout: .seconds(10))
        let flow = Task { try await signIn.callback() }
        var opened: URL?
        for _ in 0 ..< 200 where opened == nil {
            try await Task.sleep(for: .milliseconds(10))
            opened = opener.opened.first
        }
        let login = try #require(opened)
        #expect(login.host() == "steamcommunity.com")
        let items = URLComponents(url: login, resolvingAgainstBaseURL: false)?.queryItems ?? []
        let returnTo = try #require(items.first { $0.name == "openid.return_to" }?.value)
        let returnURL = try #require(URL(string: returnTo))
        #expect(returnURL.host() == "127.0.0.1")
        let port = try #require(returnURL.port.map(UInt16.init))
        _ = try await get(port, "/steam-openid/callback?openid.mode=cancel")
        let result = try await flow.value
        #expect(result.configuration.returnTo == returnTo)
        #expect(result.url.query()?.contains("openid.mode=cancel") == true)
    }

    @Test func browserSignInTimeoutIsReportedHonestly() async {
        let signIn = LoopbackSteamBrowserSignIn(opener: RecordingURLOpener(), timeout: .milliseconds(50))
        await #expect(throws: SteamSignInError.timedOut) { _ = try await signIn.callback() }
    }
}
