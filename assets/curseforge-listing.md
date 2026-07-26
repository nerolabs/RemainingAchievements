# CurseForge listing copy

Paste-ready text for the CurseForge project page. The logo to upload as the
project avatar is `logo-512.png` in this folder. Paste the description using
the portal's **Markdown editor mode** — the WYSIWYG editor treats markdown
as literal text.

## Summary (short field)

Adds a "Remaining" tab to the Achievement UI: every incomplete achievement in
one searchable list — stash-for-later, hidden achievements, opposite-faction
view, spreadsheet export.

## Description

**Ever wondered what's actually left?** The default Achievement UI makes you
click through every category to find what you haven't done. Remaining
Achievements adds a fourth tab — **Remaining** — that lists every incomplete
achievement on your account in one flat, scrollable, searchable list.

### Features

- **One list, all categories.** Native Blizzard achievement rows: icon, points
  shield, tooltips, click to expand objectives, shift-click to link in chat.
  Progressive chains show their later steps too, not just the current one.
- **Search** by name or description.
- **Stash for later.** Click the X on a row (or right-click) to set aside an
  achievement you'll never do. "Show stashed for later (N)" reveals them again
  with one-click restore. Persists account-wide.
- **Hidden achievements** *(beta)*. A toggle surfaces the point-carrying
  achievements Blizzard hides from the UI until they're earned — the ones the
  community calls hidden achievements.
- **Feats of Strength — obtainable only** *(beta)*. A toggle shows the feats
  you can still actually earn, current season included; retired promotions,
  old seasonal rewards, realm firsts, and dead one-time events are filtered
  out.
- **Opposite faction** *(beta)*. Log a character of your other faction and
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
- **Plays nice with ElvUI** — the tab picks up your skin.

### Usage

Open achievements (`Y`) and click the **Remaining** tab. That's it.

### Notes

- "Remaining" uses the same account-wide completion semantic as the default UI.
- Beta toggles are filtered from game data that doesn't track obtainability —
  if something unobtainable slips through (or something real is missing),
  please report it and it'll be fixed in the next update.
- Retail only; guild achievements are out of scope.
- Bugs and requests: https://github.com/nerolabs/RemainingAchievements/issues
