# Maintainer handoff: RemainingAchievements

**Status:** v0.7.0 shipped 2026-07-27 (CurseForge project 1626227, slug
`remaining-achievements`; GitHub nerolabs/RemainingAchievements). v0.7.0 added
full UI localization (10 machine-translated locales). This file replaces the
original pre-v0.1 research handoff; git history has that version if you need the
deep Blizzard-UI source references.

## What it is

A retail addon adding a 4th "Remaining" tab to the Blizzard Achievement UI:
every incomplete achievement on the account in one searchable list, with
stash-for-later, category filter, spreadsheet (TSV) export, an opposite-faction
view, a hidden-achievements toggle, and an obtainable-only Feats of Strength
toggle (the one still labelled beta — its obtainability is derived data, not a
game-provided flag). Fully localized (10 languages, machine-translated).

## Architecture

| File | Role |
|---|---|
| `Core.lua` | SavedVariables, async scanner (time-sliced coroutine, 5ms/frame), discovery pass, faction snapshots, event loader |
| `UI.lua` | Tab + panel + ScrollBox list, toggles, counts header, scanning indicator, ElvUI skin hook. User-facing strings via `local L = RA.L` |
| `Export.lua` | TSV builder + copy dialog (columns: ID..Stashed, Hidden, Faction, WowheadURL). Dialog chrome via `L`; TSV column headers stay English (data contract) |
| `Locales/*.lua` | Localization. `enUS.lua` builds `RA.L` (metatable falls back to the key → missing translations render English, never error) and is the canonical key list; `deDE/esES/esMX/frFR/itIT/koKR/ptBR/ruRU/zhCN/zhTW` self-gate on `GetLocale()` and override. Loaded first in the TOC. Diagnostics (/radiagnose,/raseason) stay English by design |
| `FactionData.lua` | Generated: faction-locked achievement IDs (API exposes no faction) |
| `FoSData.lua` | Generated: obtainable hidden FoS allowlist. Entry is `true` (evergreen) or `{season=N}` (seasonal, obtainable only while global M+ season N is live — resolved at runtime, so seasons self-expire) |
| `tools/` | `fetch-db2.sh` (Achievement/Achievement_Category/DisplaySeason CSVs → `tools/db2/`, gitignored), `update-faction-data.sh`, `update-fos-data.sh`, `test-fos.lua` (regression guard), `probe-season.lua` (in-game season probe) |

### How the list is built (Core.lua `BuildRemaining`)

1. **Category walk** over `GetCategoryList()` — the incomplete tail of each
   category (the client lists completed first), walking `GetNextAchievement()`
   chains so later steps of progressive chains appear. FoS categories only
   when the toggle is on, minus retired subcategories (Promotions 15268,
   PvP 15270, Events 15274) and realm-first flags (0x100|0x200).
2. **Discovery pass** (hidden/FoS toggles): brute-force IDs 1..max, keep valid
   achievements not in the visible set. Pointed non-FoS → hidden toggle;
   FoS → only if `IsObtainableFoS(id, currentSeason)`: in the
   `FoSData.lua`/`OBTAINABLE_HIDDEN_FOS` allowlist AND (evergreen OR its
   `{season=N}` == the live season from `GetEffectiveMythicPlusSeason()`).
   Filters: `RA.factionLocked`, NOISE_FLAGS (realm-first, 0x100000 internal
   tracking copies, 0x1000000 [DNT] internal), `UNOBTAINABLE` blocklist.
   **FoS candidates BYPASS the visible-category requirement** (that gate exists
   only to keep the "Legacy" tree out of the *secret* path; FoS subcategories
   empty for the current character are absent from GetCategoryList, so gating FoS
   on it wrongly drops them — FoS is allowlist-gated and never under Legacy).
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
  (checked every column incl. LegacyAfterTimeEvent) — there is no per-row
  obtainability flag. The criteria layer has none either (verified 2026-07-26
  against CriteriaTree/Criteria/ModifierTree: expired vs current Keystone Master
  trees identical, bare Type-250 rating check; Challenge Master / Keystone
  Victor / gladiator mounts have NO modifier trees; Type-289 "time event"
  references a client-absent TimeEvent table). Do not re-investigate for a flag.
- **Obtainability is instead RESOLVED AT RUNTIME (2026-07-27 redesign).** The
  generator tags each seasonal feat with its global M+ season number, derived
  from its title/description ("<Expansion> Season N") via `DisplaySeason.db2`
  (whose `Season` column == the number `C_MythicPlus.GetCurrentSeason()` returns
  live). The addon shows a `{season=N}` feat only while `N == effective current
  season`, so past seasons self-expire and new ones appear with no regen. This
  REPLACED the old per-season `CURRENT_MARKERS` text heuristic (deleted). Classes
  whose season isn't in the text: PvP (dropped if not season-derivable — all
  obtainable PvP feats carry a season) and raid AotC/Cutting Edge (tagged via the
  small hand-kept `RAID_TIER_SEASON` instance→season map — db2 has NO raid
  instance→season link; add a raid's Instance_ID when a new tier ships).
- **GetCurrentSeason() returns -1 until `C_MythicPlus.RequestMapInfo()` populates
  it** (called on load); guard `<=0` and fall back to the `newMythicPlusSeason`
  CVar. There is NO "season loaded" event — `MYTHIC_PLUS_CURRENT_SEASON_UPDATE`
  does not exist and RegisterEvent throws on it. `DisplaySeason` is datamined
  AHEAD of live (had a season-18 row while live was 17) — trust the API, not the
  max row.
- **No faction field in the API** and `Shares_criteria` is 0 on all 1258
  faction-locked rows — there is no structural mirror-pair link.
- Never full-rescan on `CRITERIA_UPDATE` (fires constantly); full rescan on
  `ACHIEVEMENT_EARNED` is correct (indexes shift, chains reveal).
- Anchor rects by exactly two opposite corners; when widening a multi-return
  function, grep every destructuring caller.
- **Localization: a translated value must preserve its key's exact `%s`/`%d`
  specifiers** (same count AND order — WoW `format` supports `%1$s` positional
  args if a language must reorder). A dropped specifier errors the tooltip at
  runtime. Keys are the English text; `RA.L` falls back to the key, so a missing
  translation renders English and never crashes. Faction display names come from
  Blizzard's localized `FACTION_HORDE`/`FACTION_ALLIANCE` globals — never
  hardcode "(Horde)"/"(Alliance)". Diagnostics + TSV column headers stay English.

## Recurring chores

- **Seasonal FoS no longer needs a per-season edit** — feats self-expire via the
  runtime resolver. Regen (`tools/update-fos-data.sh`) only to pick up
  newly-datamined feats. Being late just misses new feats; it never shows dead
  ones. Per-*expansion* (rare): add the expansion's name→ExpansionID to
  `EXPANSIONS` in the generator. Per-*raid-tier*: add the raid's Instance_ID to
  `RAID_TIER_SEASON`. Run `tools/test-fos.lua` after any regen (regression guard).
- **Data freshness rule (Andrew's):** any achievement-data analysis must use
  `tools/db2/` CSVs less than a week old — run `tools/fetch-db2.sh` first.
- **From reports:** grow `UNOBTAINABLE` / `OBTAINABLE_HIDDEN_FOS` in Core.lua.
  `/radiagnose <id>` in-game prints a full trace of why an achievement does or
  doesn't show — ask testers to paste it.
- **Post-patch validation:** the deterministic pointed-hidden set (flags
  0x800, points>0, non-Legacy/FoS) should be covered by the hidden toggle;
  it was 8 obtainable achievements on 2026-07-26.
- **New UI text:** add the English string as a key in `Locales/enUS.lua` and
  reference it via `L["..."]`; other locales fall back to English until
  translated. Machine translations are hand-added to the locale files. CF
  community-localization (seed files prepped in gitignored
  `tools/local/cf-localization/`, `@localization@` token migration) is
  BACKLOGGED pending demand — see the roadmap memory.

## Dev & release workflow

- `./dev-deploy.sh` — rsyncs into the local WoW install AND cuts a gitignored
  tester zip (`RemainingAchievements-<ver>-dev-<timestamp>.zip`, same layout
  as the release packager). Ships the `Locales/` folder (anchored rsync
  includes + zip staging — unanchored `*.lua` would either skip the subfolder
  or drag in `tools/*.lua`). Then `/reload` in-game. Andrew tests in-game
  (ElvUI + BugSack) before anything is tagged.
- Release: bump `## Version` in the TOC, commit, `git tag vX.Y.Z`,
  `git push origin main vX.Y.Z` — the GitHub workflow (BigWigsMods/packager)
  uploads to CurseForge + GitHub Releases automatically.
- CurseForge listing edits: authors portal → project 1626227; paste
  description in **Markdown editor mode** (WYSIWYG mangles markdown). Copy
  source of truth: `assets/curseforge-listing.md`.
