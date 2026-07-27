# CurseForge listing copy

Paste-ready text for the CurseForge project page. The logo to upload as the
project avatar is `logo-512.png` in this folder; gallery screenshots live in
`screenshots/`. Paste the description using the portal's **Markdown editor
mode** — the WYSIWYG editor treats markdown as literal text.

## Summary (short field)

Adds a "Remaining" tab to the Achievement UI: every incomplete achievement in
one searchable, filterable list — stash, hidden achievements, Feats of Strength,
opposite-faction view, and spreadsheet export. For completionists & achievement
hunters.

(Kept to ≤256 chars — the new-site summary field caps there and truncates
mid-word above it.)

## Description

**Ever wondered what's actually left?** The default Achievement UI makes you
click through every category to find what you haven't done. Remaining
Achievements adds a fourth tab — **Remaining** — that lists every incomplete
achievement on your account in one flat, scrollable, searchable list. A proper
achievement tracker for completionists and achievement hunters.

*Many of the features below started as community requests and bug reports —
thank you, and please keep the feedback coming.*

## Features

- **One list, all categories.** Native Blizzard achievement rows: icon, points
  shield, tooltips, click to expand objectives, shift-click to link in chat.
  Progressive chains show their later steps too, not just the current one.
- **Search** by name or description.
- **Filter by category.** A dropdown of checkboxes (all on by default) lets you
  hide whole top-level categories — PvP, Pet Battles, Delves, Housing, whatever
  you don't chase — from the list, the counts, and the export.
- **Stash for later.** Click the X on a row (or right-click) to set aside an
  achievement you'll never do. "Show stashed for later (N)" reveals them again
  with one-click restore. Persists account-wide.
- **Hidden achievements**. A toggle surfaces the point-carrying
  achievements Blizzard hides from the UI until they're earned — the ones the
  community calls hidden achievements.
- **Feats of Strength — obtainable only** *(beta)*. A toggle shows the feats
  you can still actually earn, current season included; retired promotions,
  old seasonal rewards, realm firsts, and dead one-time events are filtered
  out.
- **Opposite faction**. Log a character of your other faction and
  open the tab once — after that, a toggle shows the achievements only that
  faction can still earn, tagged (Horde)/(Alliance), with combined
  "(+N Horde)" totals in the header. Built for DataForAzeroth-style
  completionists who track both sides.
- **Spreadsheet export.** One click builds a table (ID, name, category,
  points, description, reward, Wowhead link, stashed/hidden/faction flags).
  Copy it, then paste directly into Google Sheets or Excel — it lands as
  proper columns, no file or import step needed.
- **Right-click menu** on any row: stash/restore, track on the objectives
  HUD, link to chat.
- **Localized** in 10 languages — German, Spanish (EU & LatAm), French,
  Italian, Korean, Portuguese, Russian, and Chinese (Simplified &
  Traditional) — with English fallback for anything untranslated.
- **Plays nice with ElvUI** — the tab picks up your skin.

## Usage

Open achievements (`Y`) and click the **Remaining** tab. That's it.

## Notes

- "Remaining" uses the same account-wide completion semantic as the default UI.
- The Feats of Strength toggle *(beta)* is filtered from game data that
  doesn't track obtainability — if something unobtainable slips through (or
  something real is missing), please report it and it'll be fixed in the next
  update.
- Retail only; guild achievements are out of scope.
- Bugs and requests: https://github.com/nerolabs/RemainingAchievements/issues

---

Whether you're chasing a DataForAzeroth two-faction clear, hunting down your
last few achievement points, or just want to see what's left — Remaining
Achievements puts it all on one screen.

## Gallery screenshots (upload order + captions)

Files live in `assets/screenshots/`, named in gallery order. On the project
page use the **Image** button; each upload takes a Title + Description. The
first image becomes the thumbnail. (The legacy portal's `file_upload` browser
automation no longer accepts on-disk files and the native file picker can't be
driven headlessly, so these are uploaded by hand.)

1. **1-panel.png** — Title: `One list — every remaining achievement` · Desc:
   `The Remaining tab: every incomplete achievement on your account in one searchable, filterable list — with stash, hidden, Feats of Strength, opposite-faction, and export.`
2. **2-opposite-faction.png** — Title: `Opposite-faction totals` · Desc:
   `Combined "(+N Horde)" counts in the header — built for DataForAzeroth-style two-faction completionists.`
3. **3-feats-of-strength.png** — Title: `Obtainable Feats of Strength` · Desc:
   `The Feats of Strength toggle surfaces the hidden feats you can still actually earn.`
4. **4-category-filter.png** — Title: `Filter by category` · Desc:
   `A checkbox dropdown hides whole top-level categories from the list, counts, and export.`
5. **5-export.png** — Title: `Spreadsheet export` · Desc:
   `One click builds a table you paste straight into Google Sheets or Excel — proper columns, no import step.`
6. **6-stash.png** — Title: `Stash for later` · Desc:
   `Set aside achievements you'll never do; a toggle brings them back with one-click restore. Persists account-wide.`
7. **7-hidden.png** — Title: `Hidden achievements` · Desc:
   `Surface the point-carrying achievements Blizzard hides from the UI until they're earned.`
8. **8-tab.png** — Title: `A native Remaining tab` · Desc:
   `Adds cleanly alongside Achievements, Guild, and Statistics — using Blizzard's own UI.`
