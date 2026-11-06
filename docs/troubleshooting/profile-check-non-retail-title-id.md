# Profile check fails on a non-retail title ID

*Seeded case `profile-check-non-retail-title-id` in
`Playrite/Features/NXNative/Resources/TroubleshootingKnowledgeBase.json`.*

## Symptom
The build stops during the engine's profile check with an error such as "profile check failed" or "non-retail
title ID", although the title is 64-bit and all staged files are present. Playrite's preflight shows a **warning**
(not a failure) for title IDs that do not start with `01`.

## Cause
The user-supplied engine script only accepts title IDs in the retail range (`01…`). Homebrew, development and some
region-variant builds use other IDs and are rejected before conversion starts.

## Fix (guided in Playrite → NXNative Builds → Known Issue / Knowledge Base)
Every step can be previewed first; mutating steps are backup-first and reversible; all actions go to the audit log
(`~/Library/Application Support/Playrite/Audit/audit.jsonl`).

1. **Back up the engine script** — copied to `~/Library/Application Support/Playrite/Backups/<name>.<timestamp>.bak`;
   the SHA-256 is recorded and the copy is verified before continuing.
2. **Patch the profile check** — a literal search/replace that must match **exactly once**. The suggested patch is a
   template; edit the search text to match your engine's actual check. Refused unless the backup is intact *and* the
   script is unchanged since the backup.
3. **Rebuild** — re-queues the failed job with the patched script.
4. **Restore the script** — writes the backup's bytes back in place (permissions preserved).
5. **Verify the restore** — compares bytes and SHA-256 with the backup. The case closes only when this passes.

"Revert Patch" at any time restores and verifies the original script.

## Notes
- Playrite never ships the engine, keys, firmware or games; this case only edits the user's own local engine script.
- Steps run strictly in order; out-of-order attempts are refused without touching files.
