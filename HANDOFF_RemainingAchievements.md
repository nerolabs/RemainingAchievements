# Maintainer handoff: RemainingAchievements

**Status:** v0.3.0 shipped 2026-07-26 (CurseForge project 1626227, slug
`remaining-achievements`; GitHub nerolabs/RemainingAchievements). This file
replaces the original pre-v0.1 research handoff; git history has that version
if you need the deep Blizzard-UI source references.

## What it is

A retail addon adding a 4th "Remaining" tab to the Blizzard Achievement UI:
every incomplete achievement on the account in one searchable list, with
stash-for-later, spreadsheet (TSV) export, and three beta toggles — hidden
achievements, obtainable-only Feats of Strength, and an opposite-faction view.

## Architecture

| File | Role |
|---|---|
| `Core.lua` | SavedVariables, async scanner (time-sliced coroutine, 5ms/frame), discovery pass, faction snapshots, event loader |
| `UI.lua` | Tab + panel + ScrollBox list, toggles, counts header, scanning indicator, ElvUI skin hook |
| `Export.lua` | TSV builder + copy dialog (columns: ID..Stashed, Hidden, Faction, WowheadURL) |
| `FactionData.lua` | Generated: faction-locked achievement IDs (API exposes no faction) |
| `FoSData.lua` | Generated: obtainable hidden FoS allowlist (evergreen + current season) |
| `tools/` | `fetch-db2.sh` (wago.tools CSV exports → `tools/db2/`, gitignored), `update-faction-data.sh`, `update-fos-data.sh` |

### How the list is built (Core.lua `BuildRemaining`)

1. **Category walk** over `GetCategoryList()` — the incomplete tail of each
   category (the client lists completed first), walking `GetNextAchievement()`
   chains so later steps of progressive chains appear. FoS categories only
   when the toggle is on, minus retired subcategories (Promotions 15268,
   PvP 15270, Events 15274) and realm-first flags (0x100|0x200).
2. **Discovery pass** (hidden/FoS toggles): brute-force IDs 1..max, keep valid
   achievements not in the visible set. Pointed non-FoS → hidden toggle;
   FoS → only if in the `FoSData.lua`/`OBTAINABLE_HIDDEN_FOS` allowlists.
   Filters: `RA.factionLocked`, NOISE_FLAGS (realm-first, 0x100000 internal
   tracking copies, 0x1000000 [DNT] internal), visible-category requirement
   (kills the hidden "Legacy" tree = retired content), `UNOBTAINABLE`
   blocklist.
3. **Opposite-faction merge** (toggle): every completed scan records the
   faction's plain remaining IDs to `db.factionRemaining[faction]`; the other
   faction replays it minus own-visible IDs, same-name achievements (faction
   copies like Master of Isle of Conquest), account-completed, and 0-point
   entries. The recording client does the faction filtering natively.

### Hard-won invariants (do not relearn these the painful way)

- **elementData with `index` renders via `GetAchievementInfo(cat, index)`;
  without it, by-id.** Blizzard's `CalculateSelectedHeight` has NO by-id
  fallback — UI.lua ships a verified local mirror for index-less rows.
- **Never overwrite Blizzard functions** (`## Secure: 1` era); hooksecurefunc
  only. Row OnClick must be replaced per-row (Blizzard's ProcessClick selects
  against a file-local behavior).
- **Every FoS achievement is hidden-until-earned (flag 0x800)** — the visible
  walk never yields unearned FoS; the allowlist is the only source.
- **Expired seasonal feats are byte-identical to obtainable ones in the data**
  (checked every column incl. LegacyAfterTimeEvent). Only the current-season
  markers in `tools/update-fos-data.sh` distinguish them.
- **No faction field in the API** and `Shares_criteria` is 0 on all 1258
  faction-locked rows — there is no structural mirror-pair link.
- Never full-rescan on `CRITERIA_UPDATE` (fires constantly); full rescan on
  `ACHIEVEMENT_EARNED` is correct (indexes shift, chains reveal).
- Anchor rects by exactly two opposite corners; when widening a multi-return
  function, grep every destructuring caller.

## Recurring chores

- **Each season (important):** edit `CURRENT_MARKERS` in
  `tools/update-fos-data.sh` (new season branding strings), run it and
  `tools/update-faction-data.sh`, release. Without this the FoS toggle ages.
- **Data freshness rule (Andrew's):** any achievement-data analysis must use
  `tools/db2/` CSVs less than a week old — run `tools/fetch-db2.sh` first.
- **From reports:** grow `UNOBTAINABLE` / `OBTAINABLE_HIDDEN_FOS` in Core.lua.
- **Post-patch validation:** the deterministic pointed-hidden set (flags
  0x800, points>0, non-Legacy/FoS) should be covered by the hidden toggle;
  it was 8 obtainable achievements on 2026-07-26.

## Dev & release workflow

- `./dev-deploy.sh` — rsyncs into the local WoW install AND cuts a gitignored
  tester zip (`RemainingAchievements-<ver>-dev-<timestamp>.zip`, same layout
  as the release packager). Then `/reload` in-game. Andrew tests in-game
  (ElvUI + BugSack) before anything is tagged.
- Release: bump `## Version` in the TOC, commit, `git tag vX.Y.Z`,
  `git push origin main vX.Y.Z` — the GitHub workflow (BigWigsMods/packager)
  uploads to CurseForge + GitHub Releases automatically.
- CurseForge listing edits: authors portal → project 1626227; paste
  description in **Markdown editor mode** (WYSIWYG mangles markdown). Copy
  source of truth: `assets/curseforge-listing.md`.
