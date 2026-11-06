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
