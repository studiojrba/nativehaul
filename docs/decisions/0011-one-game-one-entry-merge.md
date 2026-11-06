# ADR 0011 — One game, one entry: merge same-titled duplicates

**Status:** Accepted · 2026-11-06

## Context
After the logbook import (141 games), the 17 Switch ports existed twice. One entry came from the folder scan
(tracked `.app` path and Mac sessions). The other came from the import (status, hours, description, series, guide,
HLTB id). The scan ran first, so its title-linking could not help, and the import matched only by identifier.
J.R's rule: merge each pair into one entry, delete the duplicate, and keep all relevant data.

## Decision
- **Match:** the normalised title (`TitleNormalizer`). Entries that point at two different `.app` bundles or two
  different Steam app IDs are never merged.
- **Survivor:** the richest entry (status set, description, self-reported hours, guides, HLTB id, dates, cover).
  Ties go to the earliest added. The survivor keeps its ID, so archive series references and the HLTB cache stay valid.
- **Merge (`GameMerger`):** survivor values win; the duplicate only fills gaps (bundle path, Steam app ID and
  playtime, dates). Sessions and guides move over, and nothing is summed, so playtime sources stay separate.
  Series entries and collection parents are repointed, the HLTB estimate moves over, and then the duplicate is deleted.
- **Where it runs:**
  - "Merge Duplicate Games…" (Library menu) previews every group, then merges when confirmed.
  - The same pass runs automatically after every library import and every folder scan.
  - Steam sync links an owned game to an existing entry without a Steam app by title instead of adding a new one.

## Consequences
- Existing duplicates are fixed with one confirmed action, and new ones are not created.
- Two genuinely different games with identical normalised titles would merge, unless they have different bundles or
  Steam apps. That is accepted for a personal library.
- `Game.hltbID` and `GameRecord.hltbID` are new optional fields. Older archives still decode.
