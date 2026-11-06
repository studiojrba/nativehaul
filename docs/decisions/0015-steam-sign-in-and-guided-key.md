# ADR 0015 — Steam sign-in plus a guided API key step

**Status:** Accepted · 2026-11-06

## Context
Typing a SteamID64 and a Web API key by hand was the only way to connect Steam. J.R wants "Sign in through
Steam", followed by a plain-language step for getting the key. Steam's OpenID sign-in only proves who the user
is. Reading the library, playtime and achievements still needs a Web API key, and the UI must never suggest
otherwise.

## Decision
- **Explicit states** (`SteamSetupStage`), derived from what is stored: **signed out** (no SteamID), **signed
  in, key needed** (SteamID but no key), and **ready to sync** (both). Settings → Steam and the Steam screen's
  empty state show the same `SteamConnectionView`.
- **Sign-in:**
  - Steam OpenID 2.0 runs in `ASWebAuthenticationSession`, which catches the redirect to the
    `retriever://steam-openid/callback` custom scheme. Playrite never sees the Steam password.
  - The reply is checked locally (`SteamOpenIDResponseValidator`):
    - `mode` is `id_res` and the OpenID 2.0 namespace is correct.
    - `op_endpoint` is Steam's.
    - `return_to` is ours.
    - A signature is present, and every required field is signed.
    - `claimed_id` equals `identity`, and both are a Steam identity URL holding a valid SteamID64.
  - Steam then confirms the reply with `check_authentication` (`SteamOpenIDVerifier`). Only an `is_valid:true`
    answer stores the SteamID64. Cancelling, any failed check, or an unreachable Steam stores nothing.
- **Key step:**
  - The copy, close to J.R's words: the key is required to read the library, playtime and achievements, and
    sign-in alone can't do it.
  - Four numbered steps, with a button that opens `steamcommunity.com/dev/apikey`, then a paste field.
  - Saving puts the key in the Keychain, then checks it with one `GetPlayerSummaries` call. That call also
    supplies the account name and avatar.
  - A key Steam rejects is removed again, and the screen says so.
  - The avatar is downloaded, not hotlinked.
- **Private profiles:** when the summary shows a private profile, or a sync gets no game data, the screen says
  the game details are private. It names the exact settings (**Game details → Public**, and untick **Always
  keep my total playtime private**) and links to Steam's privacy settings page.
- **Manual fallback:** the old SteamID64 and key fields stay available under "Enter details manually".
- **Sign Out** forgets the SteamID only. **Remove Key** deletes the key from the Keychain.

## Consequences
- **The custom-scheme realm hasn't been tried against live Steam.** `retriever://steam-openid/` is unusual for
  OpenID. If Steam refuses it, the fix is a different `SteamOpenIDConfiguration` (for example, an https return
  page that forwards to the app). The validator and verifier don't change. The manual fallback keeps setup
  possible in the meantime.
- `SteamSyncing` gains `loadProfile()`, and `SteamClientProtocol` gains `playerSummary(credentials:)`.
- Playtime and metadata rules are unchanged. Signing in or out never touches library data.

## Amendment — QA Finding #1 (2026-11-06): loopback redirect replaces the custom scheme
**What happened:** J.R tried Sign in through Steam during onboarding, and Steam answered **"Invalid return
protocol."** Steam's OpenID endpoint accepts only http(s) `return_to` and `realm` values. It rejects custom URL
schemes, so the `retriever://` + `ASWebAuthenticationSession` design above could never work against real Steam.
The mocked tests passed because they never reached the real endpoint. That risk was listed under Consequences
above, but it was not checked before landing.

**Decision:** use the standard desktop pattern, a loopback redirect (RFC 8252):
- A **one-shot HTTP listener on 127.0.0.1** binds to a port the system chooses (`LoopbackCallbackServer`, Network
  framework), so it can't clash with another app.
- The request uses `return_to = http://127.0.0.1:<port>/steam-openid/callback` and
  `realm = http://127.0.0.1:<port>/`.
- Sign-in opens in the **user's own browser**, where they're usually already signed in to Steam.
- The listener answers exactly one request to the callback path with a short "you can close this tab" page, then
  shuts down. Stray requests, such as `/favicon.ico`, get a 404 and don't end the wait.
- The reply is then validated locally and confirmed with Steam's `check_authentication` **exactly as before**.
  Only a confirmed reply stores the SteamID64.
- **Honest states:**
  - **timeout** (5 minutes; covers a closed tab, which can't be detected directly);
  - **Cancel** (a button while waiting);
  - **couldn't listen** (the port couldn't be opened; points to manual entry);
  - Steam's own "cancel".
  The listener is shut down in every case.
- **Everything stays on the device.** A hosted redirect domain was considered and rejected for the trust
  posture. The listener binds only to 127.0.0.1, never to other interfaces.
- The manual SteamID64 + API key fallback is unchanged.

**Removed:** `WebAuthenticationSessionRunner`, `SteamWebAuthenticating` and the `retriever://` configuration.
**Added:** `SteamBrowserSigningIn` (live `LoopbackSteamBrowserSignIn`, mock `MockSteamBrowserSignIn`),
`LoopbackCallbackServer` and `LoopbackHTTPRequest`. The listener tests use a real loopback socket: one-shot
behaviour, stray requests, timeout, cancel, distinct ports, and a full browser round trip with a stubbed opener.

**Still to verify live:** J.R retesting against real Steam.
