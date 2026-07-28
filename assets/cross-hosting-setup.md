# Cross-hosting setup: WoWInterface + Wago Addons

Goal: list Remaining Achievements on WoWInterface and Wago in addition to
CurseForge, and have every future `vX.Y.Z` tag auto-publish to all three via
the existing BigWigsMods packager CI (`.github/workflows/release.yml`).

The CI is already wired: it passes `WOWI_API_TOKEN` and `WAGO_API_TOKEN` to the
packager. Each target stays skipped until BOTH its TOC id and its repo secret
exist — so nothing changes for existing releases until the steps below are done.

Angle to use in both listings: completionist / achievement-hunter tool
(DataForAzeroth two-faction tracking, obtainable Feats of Strength, spreadsheet
export) — NOT a generic quality-of-life addon.

---

## WoWInterface

1. Sign in / create an account at https://www.wowinterface.com.
2. Add-ons → "Compatible" → upload a new addon (or Author portal → Add File).
   Fill title "Remaining Achievements", category Achievements/Data.
3. Paste the listing from `assets/wowinterface-listing.txt` (BBCode) into the
   Description. Upload the 8 screenshots from `assets/screenshots/` (order 1..8)
   and `assets/logo-512.png` as the icon.
4. After the project exists, note its numeric **WoWI ID** (in the addon URL,
   e.g. `.../info<ID>-RemainingAchievements.html`).
5. Add to `RemainingAchievements.toc`:  `## X-WoWI-ID: <ID>`
6. Generate an API token:
   https://www.wowinterface.com/downloads/filecpl.php?action=apitokens
7. Add it as a repo actions secret named **WOWI_API_TOKEN**
   (GitHub → repo → Settings → Secrets and variables → Actions → New secret).

## Wago Addons

1. Sign in / create an account at https://addons.wago.io.
2. Create a new project (Achievements category), name "Remaining Achievements".
3. Paste the summary + Description per `assets/wago-listing.md` (which reuses
   the CurseForge markdown). Upload the 8 screenshots + logo.
4. Note the project's **Wago ID** (Project → General, an alphanumeric slug/id).
5. Add to `RemainingAchievements.toc`:  `## X-Wago-ID: <ID>`
6. Generate an API key: https://addons.wago.io/account/apikeys
7. Add it as a repo actions secret named **WAGO_API_TOKEN**.

---

## After both are set up

- Commit the two new TOC lines (`X-WoWI-ID`, `X-Wago-ID`).
- The **next** `vX.Y.Z` tag will publish to CurseForge + WoWInterface + Wago +
  GitHub Releases automatically. To publish the *current* version without a new
  release, cut a small patch tag, or upload the current zip manually once.
- Screenshots/gallery are still per-host manual uploads (same as CF) — the
  packager publishes the addon file + description, not gallery images.
