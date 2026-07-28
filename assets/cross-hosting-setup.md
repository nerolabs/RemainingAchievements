# Hosting & publishing

Remaining Achievements is published on **CurseForge** and **Wago Addons**.
Every `vX.Y.Z` tag auto-publishes to both (plus a GitHub Release) via the
BigWigs packager in `.github/workflows/release.yml`. Each host is skipped
unless BOTH its TOC id and its repo secret are present.

| Host | TOC id | Secret | Status |
|---|---|---|---|
| CurseForge | `## X-Curse-Project-ID: 1626227` | `CF_API_KEY` | live since v0.1 |
| Wago Addons | `## X-Wago-ID: mNw71WNo` | `WAGO_API_TOKEN` | set up 2026-07-28 |

## Wago notes
- Project: https://addons.wago.io/addons/remainingachievements (GitHub-linked;
  description auto-pulled from README).
- Gallery screenshots are a manual upload on the project's **Gallery** tab
  (the packager publishes the addon file + description, not gallery images) —
  use `assets/screenshots/` in order 1..8.
- The packager only fires on a *new* version tag, so the current build lands on
  Wago at the next release (or via a one-off manual upload of the release zip).

## WoWInterface — evaluated and dropped (2026-07-28)
Considered as a third host but skipped: the site and its community are in deep
decline (dead forums, most users migrated to CurseForge/Wago), so incremental
reach over CF + Wago wasn't worth the manual, moderation-gated setup. The
packager still supports it (`## X-WoWI-ID` + `WOWI_API_TOKEN`) if that ever
changes.
