#if DEBUG
    import Foundation

    /// The screenshot harness's build engine (note 9): prints nxnative-style progress for a build part-way through,
    /// then holds there until cancelled, so Builds and Detail show a live build with a real-looking log. It runs
    /// nothing.
    struct HarnessBuildEngineRunner: BuildEngineRunning {
        /// The lines printed before it holds.
        static let lines = [
            "[10:02:11] [1/5] extract · unpacking…",
            "[10:02:40] ✓ [1/5] extract (0:29)",
            "[10:02:41] [2/5] verify · hashing…",
            "[10:02:53] ✓ [2/5] verify (0:12)",
            "[10:02:54] [3/5] update · applying update and DLC…",
            "[10:03:20] ✓ [3/5] update (0:26)",
            "[10:03:21] [4/5] rewrite · step …",
            "[10:04:23] [4/5] rewrite · step: 64%, 3.1/~4.8 GB, 1:02 · ETA 0:35",
        ]

        func run(_: EngineInvocation) -> AsyncThrowingStream<BuildLogLine, Error> {
            AsyncThrowingStream { continuation in
                for line in Self.lines {
                    continuation.yield(BuildLogLine(timestamp: .now, stream: .stdout, text: line))
                }
            }
        }
    }
#endif
