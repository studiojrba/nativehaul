# Privacy

nativehaul has **no telemetry**: no analytics, no crash reporting service, no usage pings and no account. Nothing
about the user or their library is sent anywhere. Keys the user pastes (RetroAchievements, SteamGridDB, IGDB) are
stored only in the macOS Keychain and are sent only to the service they belong to.

These are the only hosts nativehaul contacts or links to. `ReleasePolicyTests` fails if source code names a host
that is not in this table.

| Host | When | What is sent |
|---|---|---|
| `raw.githubusercontent.com` | Fetching the titledb Switch title list (when the cached copy is over 30 days old) | Nothing beyond the request |
| `api.github.com` | Checking emulator releases (at most once a day) | Nothing beyond the request |
| `github.com` | Opening nativehaul's releases page, and downloading emulators the user chose to install | Nothing beyond the request |
| `buildbot.libretro.com`, `dl.dolphin-emu.org` | Downloading an emulator the user chose to install | Nothing beyond the request |
| `retroachievements.org`, `media.retroachievements.org` | Only with the user's RetroAchievements key | Username, API key, the matched game's ID or a ROM hash |
| `id.twitch.tv`, `api.igdb.com`, `images.igdb.com` | Only with the user's IGDB credentials | Client ID and secret (for a token), game titles |
| `www.steamgriddb.com` (and the image hosts it returns) | Only with the user's SteamGridDB key | API key, game titles |
| `www.youtube-nocookie.com`, `www.youtube.com`, `i.ytimg.com` | Showing a trailer on a game page | The video ID |
| `howlongtobeat.com`, `gamefaqs.gamespot.com` | Only when the user clicks a link (opens in the browser) | Nothing from nativehaul |
| `www.retroarch.com`, `dolphin-emu.org`, `pcsx2.net`, `melonds.kuribo64.net`, `www.ppsspp.org` | Only when the user clicks an emulator's official page | Nothing from nativehaul |
| `com.studiojrba.nativehaul` | The trailer player's page origin label (YouTube needs a referrer); never contacted | Nothing |
| `example.com` | SwiftUI previews only, never in the running app | Nothing |

Network requests carry only what each request needs. Like any connection, they reveal the Mac's IP address to the
host.

<!-- app-updates -->
