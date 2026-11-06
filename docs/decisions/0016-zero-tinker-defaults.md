# ADR 0016 — Zero-tinker defaults

**Status:** Accepted · 2026-11-06 · owner directive

## Context
J.R's standing rule: Retriever should be "literally just install and play, and then view hours played,
progress, and guide. No need for customizing or having to tinker with anything (unless they want to, option is
there) just to get the most useful features to work."

## Decision
- Every headline feature must deliver its full value on defaults alone. Settings and overrides stay available
  for people who want them, but none of them may be required for the core loop: install → play → hours,
  progress and guide.
- The only allowed prerequisites are credentials only the user can provide: Steam sign-in and the Steam API key.
  Each is asked for once, inline, where it's needed, with plain step-by-step guidance.
- Work that can run by itself does. When a design choice trades default convenience against configurability,
  convenience wins, and the branch's ADR says so.
- The rule is recorded in `CLAUDE.md`, so it applies to every future branch.

## Audit of the work in flight (applied on `feature/bottle-automation`)
| Area | Before | Now |
|---|---|---|
| Dedupe | Runs after imports and scans | Unchanged ✅ |
| Installed-game detection | Menu item only | Runs quietly at launch. With no folders configured it still finds CrossOver bottles, Steam installs and launchers. |
| Steam sync | Sync Now button | Runs at launch when Steam is set up, and right after the API key checks out. |
| Metadata | Fetch Missing Metadata menu item | Runs at launch and after library changes, skipping games already tried this session. The menu item stays for a full retry. |
| SteamGridDB key | Optional | Still optional. Official Steam art works with no key. |
| Steam sign-in | Settings or the Steam screen | The flow appears inline on the Steam screen; Settings isn't needed. The API key is a credential only the user has, so it stays a guided step. |
| Bottle recipes | — | Applied automatically, with nothing to choose. |
| Golden bottle | — | A lean bottle already signed in to the linked account is **adopted automatically**, without asking (convenience wins). The offer appears only when a bottle must be created, because that needs the user's sign-in anyway. |

Quiet background runs never interrupt with alerts. The manual menu items still report their results.

## Consequences
- More happens at launch: a folder scan, a Steam sync and a metadata pass. All are idempotent, and network work
  is throttled. A metadata pass skips games already tried this session, so the stores aren't asked again on
  every library change.
- Future branches must check new features against this rule before landing.
