import Foundation
import Network
import Synchronization

/// A one-shot HTTP listener on 127.0.0.1 for browser sign-in redirects (RFC 8252).
///
/// It binds to the loopback interface only, on a port the system picks (so it can't clash with another app), answers
/// exactly one request to ``callbackPath`` with a short "you can close this tab" page, and then shuts down. Other
/// requests (a browser's `/favicon.ico`, say) get a 404 and don't end the wait.
final class LoopbackCallbackServer: Sendable {
    private struct State: ~Copyable {
        var listener: NWListener?
        var portContinuation: CheckedContinuation<UInt16, any Error>?
        var callbackContinuation: CheckedContinuation<URL, any Error>?
        var received: URL?
        var failure: LoopbackCallbackError?
        var port: UInt16?
    }

    private static let maxRequestBytes = 65536
    private static let okPage = """
    <!doctype html><meta charset="utf-8"><title>NX Shelf</title>
    <body style="font: 16px -apple-system, sans-serif; margin: 3em">
    <h2>Steam sent your sign-in back to NX Shelf.</h2><p>You can close this tab and return to NX Shelf.</p>
    """

    /// The path that ends the wait.
    let callbackPath: String
    private let queue = DispatchQueue(label: "com.studiojrba.Playrite.loopback")
    private let state = Mutex(State())

    /// Creates a listener for `callbackPath`.
    init(callbackPath: String) {
        self.callbackPath = callbackPath
    }

    /// Starts listening and returns the port.
    func start() async throws -> UInt16 {
        let parameters = NWParameters.tcp
        parameters.requiredLocalEndpoint = NWEndpoint.hostPort(host: .ipv4(.loopback), port: .any)
        parameters.allowLocalEndpointReuse = false
        guard let listener = try? NWListener(using: parameters) else { throw LoopbackCallbackError.couldNotListen }
        return try await withCheckedThrowingContinuation { continuation in
            state.withLock {
                $0.listener = listener
                $0.portContinuation = continuation
            }
            listener.stateUpdateHandler = { [weak self] update in self?.listenerChanged(update, listener: listener) }
            listener.newConnectionHandler = { [weak self] connection in self?.accept(connection) }
            listener.start(queue: queue)
        }
    }

    /// Waits for the callback. Throws ``LoopbackCallbackError/timedOut`` after `timeout` and
    /// ``LoopbackCallbackError/cancelled`` when the task is cancelled. The listener is shut down either way.
    func waitForCallback(timeout: Duration) async throws -> URL {
        let timer = Task { [weak self] in
            try? await Task.sleep(for: timeout)
            if !Task.isCancelled {
                self?.finish(.failure(LoopbackCallbackError.timedOut))
            }
        }
        defer { timer.cancel() }
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                let ready: Result<URL, any Error>? = state.withLock { state in
                    if let received = state.received {
                        return .success(received)
                    }
                    if let failure = state.failure {
                        return .failure(failure)
                    }
                    state.callbackContinuation = continuation
                    return nil
                }
                if let ready {
                    continuation.resume(with: ready)
                }
            }
        } onCancel: { [weak self] in
            self?.finish(.failure(LoopbackCallbackError.cancelled))
        }
    }

    /// Shuts the listener down (idempotent).
    func stop() {
        finish(.failure(LoopbackCallbackError.cancelled))
    }

    private func listenerChanged(_ update: NWListener.State, listener: NWListener) {
        switch update {
        case .ready:
            let port = listener.port?.rawValue
            let continuation = state.withLock { state in
                state.port = port
                defer { state.portContinuation = nil }
                return state.portContinuation
            }
            if let port {
                continuation?.resume(returning: port)
            } else {
                continuation?.resume(throwing: LoopbackCallbackError.couldNotListen)
            }
        case .failed, .cancelled:
            let continuation = state.withLock { state in
                defer { state.portContinuation = nil }
                return state.portContinuation
            }
            continuation?.resume(throwing: LoopbackCallbackError.couldNotListen)
            if case .failed = update {
                finish(.failure(LoopbackCallbackError.couldNotListen))
            }
        default:
            break
        }
    }

    private func accept(_ connection: NWConnection) {
        connection.start(queue: queue)
        connection
            .receive(minimumIncompleteLength: 1, maximumLength: Self.maxRequestBytes) { [weak self] data, _, _, _ in
                guard let self else {
                    connection.cancel()
                    return
                }
                let request = data.flatMap(LoopbackHTTPRequest.init)
                let port = state.withLock { $0.port }
                guard let request, request.method == "GET", request.path == callbackPath, let port,
                      let url = URL(string: "http://\(SteamOpenIDConfiguration.loopbackHost):\(port)\(request.target)")
                else {
                    respond(connection, status: "404 Not Found", body: "")
                    return
                }
                respond(connection, status: "200 OK", body: Self.okPage)
                finish(.success(url))
            }
    }

    private func respond(_ connection: NWConnection, status: String, body: String) {
        let bytes = Data(body.utf8)
        let head = "HTTP/1.1 \(status)\r\nContent-Type: text/html; charset=utf-8\r\n"
            + "Content-Length: \(bytes.count)\r\nConnection: close\r\n\r\n"
        connection.send(content: Data(head.utf8) + bytes, completion: .contentProcessed { _ in connection.cancel() })
    }

    /// Delivers the first outcome, then stops listening. Later outcomes are ignored (one-shot).
    private func finish(_ outcome: Result<URL, any Error>) {
        let (continuation, listener): (CheckedContinuation<URL, any Error>?, NWListener?) = state.withLock { state in
            guard state.received == nil, state.failure == nil else { return (nil, nil) }
            switch outcome {
            case let .success(url): state.received = url
            case let .failure(error): state.failure = (error as? LoopbackCallbackError) ?? .cancelled
            }
            defer {
                state.callbackContinuation = nil
                state.listener = nil
            }
            return (state.callbackContinuation, state.listener)
        }
        listener?.cancel()
        continuation?.resume(with: outcome)
    }
}
