# ADR 0007 — Steam Web API key lives only in the Keychain

**Status:** Accepted · 2026-11-06

## Context
The Steam Web API requires a per-user key sent as a query parameter. Keys must never leak into code, config,
`UserDefaults`, logs, exports, or git, and the app must be fully usable without one.

## Decision
- `SecretStore` protocol; the only live implementation is `KeychainSecretStore` (generic password,
  service `com.studiojrba.Playrite`, account `steam.webapi.key`). `InMemorySecretStore` is the mock.
- `SteamAccountStore` reads the key on demand to build `SteamCredentials`; the UI only shows whether a key exists
  and never reads it back. The non-secret SteamID64 is stored in `UserDefaults`.
- `URLSessionHTTPClient` never logs URLs; `SteamError` messages never contain the key.
- Without a key, `SteamSyncService` throws `missingAPIKey` **before** any network call; Steam UI shows an
  empty state with a Settings link and the rest of the app is unaffected.

## Consequences
- Library exports never contain the key (it is not a model property).
- Unit tests never touch the real Keychain (they use `InMemorySecretStore`); the Keychain wrapper is verified manually.
