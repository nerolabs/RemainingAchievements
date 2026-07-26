# Handoff: "RemainingAchievements" — WoW addon adding a "Remaining" tab to the Achievement UI

**Audience:** Claude Code session implementing this from scratch.
**Status:** Research complete and verified against live Blizzard UI source. No code written yet.
**Date of research:** 2026-07-26.

---

## 1. What we're building

A retail WoW addon that adds a **4th tab** to the default Achievement UI (the frame opened with the `Y` keybind) labeled **"Remaining"**, showing one flat, scrollable list of **every achievement the player has not yet completed**, across all categories.

Features (agreed with the user):

1. **Remaining list** — flat list of all incomplete achievements, rendered to look native (reuse Blizzard's `AchievementTemplate` buttons: icon, points shield, description, tooltip, expand-on-click).
2. **Untrack / hide** — a per-achievement "never gonna do this" dismissal. Hidden achievements disappear from the Remaining list. Persisted in SavedVariables (account-wide). Must be reversible: a "Show hidden (N)" toggle that reveals hidden entries with a "Restore" affordance. Note: do NOT confuse with Blizzard's own "track on objectives HUD" feature (`C_ContentTracking`) — our feature is a blacklist. Consider labeling it "Hide" in the UI to avoid colliding with Blizzard's "Track" wording (user calls it "untrack"; either wording is fine, but keep it distinct from the HUD-tracking checkbox that appears on achievement buttons).
3. **Export to CSV** — button that opens a copy-paste dialog (addons cannot write files to disk; the standard pattern is a frame with a multiline EditBox + CTRL-A/CTRL-C, like SimulationCraft's addon). The user will supply a CSV template later; until then, **guess** this column set:
   `ID,Name,Category,Points,Description,RewardText,Completed,EarnedByMe,Hidden,WowheadURL`
   - Wowhead URL: `https://www.wowhead.com/achievement=<ID>`
   - CSV-escape: wrap fields in double quotes, double any embedded quotes, strip newlines from descriptions.
   - Export scope: everything currently matching the list (respect the "show hidden" toggle state, or add All/Visible radio in the export dialog — implementer's choice, keep it simple).

Optional niceties if cheap: a search/filter EditBox above the list; count header ("1,234 remaining · 4,821 points unearned"); sort dropdown (category order / points / name). Don't gold-plate; ship the three core features first.

**Target:** Retail only (Midnight, 12.0.x). No Classic support in v1.

---

## 2. Verified environment facts (researched 2026-07-26)

- Current retail live interface version: **120005** (patch 12.0.5); PTR is 120007. TOC supports a list: `## Interface: 120005, 120007`. Source: warcraft.wiki.gg/wiki/TOC_format.
- Blizzard UI reference source: `https://github.com/Gethe/wow-ui-source`, branch **`live`** (version.txt at research time: `12.0.7.68887`). **Clone this first** (sparse checkout of `Interface/AddOns/Blizzard_AchievementUI` is enough) and re-verify every line reference below — the branch moves.
- Relevant file: `Interface/AddOns/Blizzard_AchievementUI/Mainline/Blizzard_AchievementUI.lua` (~3619 lines) and `.xml` (~2706 lines). All line numbers below refer to these at the version above.
- `Blizzard_AchievementUI` is **LoadOnDemand** and its TOC has `## Secure: 1` (Midnight secure-addon era). Achievement UI has no protected actions, so taint here is historically harmless (Krowi's Achievement Filter ships a 4th/5th tab and works), but still: prefer `hooksecurefunc`, own frames, and never write Blizzard table fields you don't have to.

### 2.1 Achievement data API (all still current, no C_ replacement)

- `GetCategoryList()` → array of category IDs (player categories, includes Feats of Strength; excludes guild).
- `GetCategoryInfo(catID)` → `title, parentCategoryID, flags`. `parentCategoryID == -1` for top-level player categories (guild uses `GetGuildCategoryList()`; we ignore guild in v1).
- `GetCategoryNumAchievements(catID [, includeAll])` → `total, completed, incompleted`. **Important:** by default it only counts achievements "visible" in the UI chain (for a not-yet-completed progressive chain, only the current step is listed; completed previous steps are counted differently). This is what we want — it matches what the player sees.
- `GetAchievementInfo(catID, index)` **or** `GetAchievementInfo(achievementID)` → 15 returns:
  `id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic`.
  - `completed` = completed by anyone on the account; `wasEarnedByMe` = this character. Default semantic for "remaining": **`not completed`** (account-wide). Offer a "character mode" later only if the user asks.
- `GetNextAchievement(id)` / `GetPreviousAchievement(id)` — progressive chains. When iterating a category with `GetAchievementInfo(cat, i)`, the UI already returns the chain-appropriate entry; you generally do NOT need to walk chains yourself if you iterate `for i = 1, GetCategoryNumAchievements(cat) do`.
- `GetAchievementCategory(id)` → category ID (used by Blizzard's own Init when elementData has only `id` — see §3.3).
- Account-wide flag test (Lua, verified at line 1207): `bit.band(flags, ACHIEVEMENT_FLAGS_ACCOUNT) == ACHIEVEMENT_FLAGS_ACCOUNT` (constant in `Blizzard_FrameXMLBase/Constants.lua`).
- Feats of Strength: `FEAT_OF_STRENGTH_ID = 81`, `GUILD_FEAT_OF_STRENGTH_ID = 15093` (locals at lua:59-60). FoS achievements are "remaining" but mostly unobtainable — **exclude category 81 (and its children) by default**, with a settings toggle "Include Feats of Strength". Identify children via `GetCategoryInfo` parent chain.
- Blizzard's own filter plumbing (for reference, don't reuse): `AchievementFrameFilters` table at lua:1846 with All/Completed/Incomplete funcs; active filter in global `ACHIEVEMENTUI_SELECTEDFILTER`. Blizzard's Incomplete filter is per-category only — that's the gap this addon fills.
- HUD tracking (only if we add a "Track on HUD" convenience to the right-click menu): `C_ContentTracking.StartTracking/StopTracking/IsTracking(Enum.ContentTrackingType.Achievement, id)`, `C_ContentTracking.GetTrackedIDs(...)`.
- Scan cost: ~4–5k achievements; a full scan is fast but do it **once, cached**, refresh on `ACHIEVEMENT_EARNED` (event payload: `achievementID`) by just removing that ID, full rescan on demand.

### 2.2 Achievement UI structure (verified against source)

- Main frame: `AchievementFrame` (768×500, created hidden, XML line ~1505). LoadOnDemand addon `Blizzard_AchievementUI` — our addon must either `## LoadWith`/`## Dependencies` it or (better) listen for `ADDON_LOADED` with name `"Blizzard_AchievementUI"` and init then. Prefer the event approach with a lightweight loader (see §3.1).
- Tabs: classic PanelTemplates. `AchievementFrame_OnLoad` does `PanelTemplates_SetNumTabs(self, 3)` (lua:238). Tabs are **global-named buttons** `AchievementFrameTab1..3` (XML ~2321, `id=1..3`), template **`AchievementFrameTabButtonTemplate`** (XML:246, 115×32, has `OnShow → PanelTemplates_TabResize(self, 30)`), instance OnClick: `AchievementFrameTab_OnClick(self:GetID()); PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);`.
- `AchievementFrame_UpdateTabs(clickedTab)` (lua:337): hides SearchResults, calls `PanelTemplates_Tab_OnClick(_G["AchievementFrameTab"..clickedTab], AchievementFrame)`, then loops **`for i = 1, 3`** adjusting each tab's text Y-offset. It uses the hardcoded 3 — it will NOT touch our Tab4's text offset; replicate the -5/-3 nudge ourselves. It also won't error on tab 4.
- `AchievementFrameBaseTab_OnClick(tabIndex)` (lua:406) handles indices 1–3 via `AchievementCategoryIndex/GuildCategoryIndex/StatisticsCategoryIndex` and ends with `SwitchAchievementSearchTab(tabIndex)`.
  - **`SwitchAchievementSearchTab` is not defined anywhere in Lua** (searched entire wow-ui-source live tree) — it's provided by the C client. Unknown behavior for index 4: **wrap our call in `pcall`, or simply don't call it** for our tab (search box context just stays on the last real tab — acceptable).
- Guild tab layout juggling: `AchievementFrame_SetTabs`/`SetComparisonTabs` (lua:327-335) re-anchor Tab3 relative to Tab2/Tab1. Our Tab4 should anchor `("LEFT", AchievementFrameTab3, "RIGHT", -5, 0)` — it then follows automatically.
- Subframe switching: `AchievementFrame_ShowSubFrame(...)` iterates a **file-local** `subFramesList` (Summary, Achievements, Stats, Comparison + 2 containers) and `SetShown`s each (lua:466-491). Our panel can't be added to that local list. Strategy: when OUR tab is clicked, call `AchievementFrame_ShowSubFrame()` with no args (hides all Blizzard subframes) then show ours; hook `hooksecurefunc("AchievementFrame_ShowSubFrame", ...)`? — **No**: it's called with our panel unknown, i.e. any Blizzard call hides only Blizzard frames. Instead hide ours whenever tabs 1–3 are clicked: `hooksecurefunc("AchievementFrameBaseTab_OnClick", hideOurs)` + `hooksecurefunc("AchievementFrameComparisonTab_OnClick", hideOurs)` (comparison mode replaces `AchievementFrameTab_OnClick` wholesale, lua:201/228 — hook both named functions, not the mutable alias).
- Categories pane: `AchievementFrame.Categories` (left, width 175, anchored TOPLEFT 21,-19). Achievements pane: `AchievementFrame.Achievements` (global `AchievementFrameAchievements`), 504×440, anchored `TOPLEFT` to Categories `TOPRIGHT` +22,0 (XML ~1757). For our tab, decide: (a) mimic layout — our own left pane for controls (hide/export/toggles) + right list pane matching Achievements geometry, or (b) one full-width list. **Recommendation: (a)** — copy the exact anchors of Categories/Achievements so the frame art (watermark, gold borders, background `Interface\AchievementFrame\UI-Achievement-AchievementBackground` with texcoord 0,1,0,0.5) looks native. When our tab activates, also hide `AchievementFrameCategories` and `AchievementFrame_HideFilterDropdown(AchievementFrame)`; restore is automatic since tabs 1–3 clicks call their own setup.
- Watermark/background details when switching tabs (see `AchievementFrameBaseTab_OnClick`): `AchievementFrameWaterMark:SetTexture("Interface\\AchievementFrame\\UI-Achievement-AchievementWatermark")`, `AchievementFrameCategoriesBG:SetTexCoord(0, 0.5, 0, 1)`, hide guild emblems. Do the same when our tab activates so visuals stay coherent.

### 2.3 The modern list machinery (this is the part that changed since Dragonflight)

`AchievementFrameAchievements_OnLoad` (lua:843-885) is the pattern to copy for our own list:

```lua
local view = CreateScrollBoxListLinearView();
view:SetElementExtentCalculator(function(dataIndex, elementData)
    if SelectionBehaviorMixin.IsElementDataIntrusiveSelected(elementData) then
        return AchievementTemplateMixin.CalculateSelectedHeight(elementData);
    else
        return ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT;
    end
end);
view:SetElementInitializer("AchievementTemplate", function(button, elementData)
    button:Init(elementData);
end);
view:SetElementResetter(function(button)
    if SelectionBehaviorMixin.IsIntrusiveSelected(button) then
        button:GetObjectiveFrame():Clear();
    end
end);
view:SetPadding(2,0,0,4,0);
ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
local behavior = ScrollUtil.AddSelectionBehavior(self.ScrollBox,
    SelectionBehaviorFlags.Deselectable, SelectionBehaviorFlags.Intrusive);
-- + OnSelectionChanged callback → button:SetSelected(selected)
ScrollUtil.AddResizableChildrenBehavior(self.ScrollBox);
```

- ScrollBox frames in XML inherit `WowScrollBoxList` (frameStrata HIGH), scrollbar inherits `MinimalScrollBar` anchored to the box's right (+6 x offset). Fine to create in Lua instead.
- Element template **`AchievementTemplate`** (XML:733, an `EventButton` with mixin `AchievementTemplateMixin`, `TooltipBorderBackdropTemplate`).
- **Key verified fact:** `AchievementTemplateMixin:Init(elementData)` (lua:1157) supports elementData of the form `{id = achievementID}` with **no index/category** — it falls through to `GetAchievementInfo(self.id)` + `GetAchievementCategory(self.id)` ("Social" path, lua:1197-1203). So our data provider can be simply `CreateDataProvider(arrayOf{ {id=...}, ... })` and Blizzard's own button code renders everything: icon, shield, points, progressive points, desaturation for incomplete, reward bar, tooltip via `EventRegistry "AchievementFrameAchievement.OnEnter"`, expansion with objectives.
- Expansion/selection: `Init` checks `SelectionBehaviorMixin.IsElementDataIntrusiveSelected(elementData)` (a generic flag the selection behavior sets on elementData) → works with OUR OWN selection behavior on OUR ScrollBox. Objectives detail uses shared singleton `AchievementFrameAchievementsObjectives` — shared with Blizzard's list, but only one list is visible at a time, safe.
- **Click handling caveat (important):** `AchievementTemplateMixin:OnClick → ProcessClick` (lua:1060-1091) ends with `g_achievementSelectionBehavior:ToggleSelect(self)` — a **file-local** referencing *Blizzard's* ScrollBox behavior. A raw AchievementTemplate button inside OUR ScrollBox would corrupt/select against the wrong list. **Fix:** in our element initializer, after `button:Init(elementData)`, do `button:SetScript("OnClick", OurOnClick)` where OurOnClick reimplements the useful parts: shift-click chat link (`IsModifiedClick("CHATLINK")` → `GetAchievementLink(id)` → `ChatFrameUtil.InsertLink`), `IsModifiedClick("QUESTWATCHTOGGLE")` → `button:ToggleTracking(id)`, else `ourSelectionBehavior:ToggleSelect(button)`. Also consider right-click → context menu (see §3.4). Setting a script on a pooled frame is sticky — the same frame may later be reused by Blizzard's list? **No:** frame pools belong to each ScrollBox view, they are not shared across ScrollBoxes. Safe.
- `ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT` = global constant (84); `AchievementTemplateMixin.CalculateSelectedHeight` is a public mixin static (lua:856 usage).
- Per-frame events: `AchievementFrameAchievements_OnShow` registers `ACHIEVEMENT_EARNED`, `CRITERIA_UPDATE`, etc. via `FrameUtil.RegisterFrameForEvents`. Do the same on our panel: on `ACHIEVEMENT_EARNED(id)` remove that elementData from our provider (`dataProvider:RemoveByPredicate`) or rebuild.

### 2.4 Misc verified details

- Restricted mode exists (`AchievementFrame_SetRestrictedMode`, lua:290+, hides tabs via `PanelTemplates_SetAllTabsShown` when a GameRule restricts categories — e.g. WoW Remix-style events). Cheap safety: if `AchievementFrame.restrictedCategoryID ~= nil`, hide our tab too (hook `AchievementFrame_SetRestrictedMode`).
- Kiosk mode guards exist in Blizzard code (`Kiosk.IsEnabled()`); ignore, irrelevant.
- Filter dropdown: `AchievementFrameFilterDropdown` uses the modern menu API (`SetupMenu(function(dropdown, rootDescription) ... rootDescription:CreateRadio(...)`) — lua:252-264. Use the same modern API (`MenuUtil.CreateContextMenu` for right-click menus); the old `UIDropDownMenu_*` is legacy.
- Tab text nudge pattern (lua:341-343): selected tab text `("CENTER", 0, -5)`, unselected `-3`.
- `PanelTemplates_SetNumTabs(AchievementFrame, 4)` after creating our tab, then `PanelTemplates_UpdateTabs(AchievementFrame)`. PanelTemplates lives in Blizzard_SharedXML; API unchanged (`SetTab`, `GetSelectedTab`, `ShowTab/HideTab`, `TabResize`). Note `AchievementFrame_SetTabs`/`SetComparisonTabs` call `PanelTemplates_ShowTab/HideTab` for tab 2 — numTabs=4 is compatible.
- When our tab is selected, `AchievementFrame.selectedTab` will be 4 (PanelTemplates sets it). Blizzard code branches on `selectedTab == 1/2/3` in a few places (lua:203-221 achievement-earned toast click, lua:550, lua:790/970 guild view checks). Skimmed all `selectedTab` uses: nothing errors on 4; `InGuildView()` is `selectedTab == 2` → false, good.
- Comparison mode (inspecting another player) swaps `AchievementFrameTab_OnClick` to `AchievementFrameComparisonTab_OnClick` and calls `AchievementFrame_SetComparisonTabs` (hides tab 2). Our tab is meaningless there: hook `AchievementFrame_DisplayComparison`? Simplest verified hook points: `hooksecurefunc("AchievementFrame_SetComparisonTabs", hideOurTab)` and `hooksecurefunc("AchievementFrame_SetTabs", showOurTab)` (lua:327-335 — these are exactly the mode switch functions).

---

## 3. Implementation plan

### 3.1 Addon skeleton

```
RemainingAchievements/
├── RemainingAchievements.toc
├── Core.lua        -- saved vars, scanner, event loader
├── UI.lua          -- tab, panel, scrollbox, controls
└── Export.lua      -- CSV builder + copy dialog
```

TOC:
```
## Interface: 120005, 120007
## Title: Remaining Achievements
## Notes: Adds a "Remaining" tab listing every achievement you haven't completed yet.
## Author: Andrew
## Version: 0.1.0
## SavedVariables: RemainingAchievementsDB
## IconTexture: Interface\AchievementFrame\UI-Achievement-TinyShield
Core.lua
UI.lua
Export.lua
```

Loader pattern (Core.lua): register `ADDON_LOADED`; if `C_AddOns.IsAddOnLoaded("Blizzard_AchievementUI")` already true at our load (unlikely) init immediately, else wait for `ADDON_LOADED` arg1 == `"Blizzard_AchievementUI"`. (`C_AddOns` namespace is current; bare `IsAddOnLoaded` is removed.) Don't force-load Blizzard's addon at login — keep the LoadOnDemand benefit.

SavedVariables shape:
```lua
RemainingAchievementsDB = {
  hidden = { [achievementID] = true, ... },
  settings = { includeFoS = false, showHidden = false },
}
```

### 3.2 Scanner (Core.lua)

```lua
local function BuildRemainingList()
  local results = {};
  for _, catID in ipairs(GetCategoryList()) do
    if IncludeCategory(catID) then          -- FoS filtering via parent chain to 81
      local total = GetCategoryNumAchievements(catID);
      for i = 1, total do
        local id, _, _, completed = GetAchievementInfo(catID, i);
        if id and not completed and (showHidden or not db.hidden[id]) then
          tinsert(results, { id = id, category = catID });
        end
      end
    end
  end
  return results;
end
```
(Keeping `category` in elementData is harmless — Init only uses it when `index` is set; set `id` only, or `id`+nothing else. Verified: Init branches on `self.index`, so include `id` and DO NOT include `index`.) Cache the raw scan; rebuild data provider on: tab open, hide/restore, toggle changes, `ACHIEVEMENT_EARNED`.

### 3.3 Tab + panel (UI.lua)

- `CreateFrame("Button", "AchievementFrameTab4", AchievementFrame, "AchievementFrameTabButtonTemplate")`, `:SetID(4)`, `:SetText("Remaining")`, anchor `("LEFT", AchievementFrameTab3, "RIGHT", -5, 0)`, OnClick → `PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)` + our activate function. Then `PanelTemplates_SetNumTabs(AchievementFrame, 4); PanelTemplates_UpdateTabs(AchievementFrame);`
- Activate: `AchievementFrame_UpdateTabs(4)` (safe, verified), fix text nudges for all 4 tabs ourselves, `AchievementFrame_ShowSubFrame()` (no args → hides all Blizzard panels), hide `AchievementFrameCategories`... **wait, verify**: Categories is NOT in subFramesList (it's always shown) — hide it explicitly and re-show when tabs 1–3 activate (our hooksecurefunc on the two tab-click functions must re-show it; those handlers don't show it themselves since it's never normally hidden). Set watermark, hide filter dropdown (`AchievementFrame_HideFilterDropdown(AchievementFrame)`), show our panel, refresh list. Skip `SwitchAchievementSearchTab` or pcall it.
- Panel: our frame parented to `AchievementFrame`, replicating the Categories(left controls)/Achievements(right list) geometry from §2.2, with ScrollBox+MinimalScrollBar built per §2.3, our own selection behavior, and the OnClick override per §2.3.
- Left controls pane: "N remaining" summary, "Include Feats of Strength" checkbox, "Show hidden (N)" checkbox, "Export CSV" button, maybe search EditBox (`SearchBoxTemplate`).
- Deactivation hooks (all `hooksecurefunc`): `AchievementFrameBaseTab_OnClick`, `AchievementFrameComparisonTab_OnClick` → hide panel + re-show Categories; `AchievementFrame_SetComparisonTabs` → hide our tab button; `AchievementFrame_SetTabs` → show it; `AchievementFrame_SetRestrictedMode` → SetShown(not restricted).

### 3.4 Hide/untrack UX

- Right-click on a row → `MenuUtil.CreateContextMenu(owner, generator)` with: "Hide from Remaining" / "Restore", "Track on HUD" (via `C_ContentTracking`, optional), "Link to chat".
- Plus an inline small "X"/eye button on each row (create once per button in initializer, positioned top-right; remember buttons are pooled per-view so guard with `if not button.RemainingHideButton then create end`).
- Hiding while list shown: remove elementData from provider (nice animation not required).

### 3.5 CSV export (Export.lua)

- Build string from current list (or all remaining incl. hidden — radio choice), columns per §1.3.
- Dialog: 500×400 frame, `BasicFrameTemplateWithInset`, `ScrollFrame` + multiline `EditBox` (`SetAutoFocus(true)`, `HighlightText()` on show, `CTRL+C` hint text, OnEscapePressed → hide). EditBoxes handle ~1MB fine; 4–5k rows × ~200 chars ≈ 1MB — acceptable, but chunk if sluggish (option: export only first N + note, or per-category export later; don't optimize prematurely).

---

## 4. Gotchas summary (read before coding)

1. `SwitchAchievementSearchTab` is client-native, not Lua — don't call with index 4 (skip/pcall).
2. `AchievementTemplateMixin:ProcessClick` touches Blizzard's file-local selection behavior — always override OnClick on our rows.
3. elementData must have `id` but NOT `index`, to hit the by-ID path in `Init`.
4. `AchievementFrame_UpdateTabs` only styles tabs 1–3 — nudge Tab4 text manually.
5. Categories pane is not part of `AchievementFrame_ShowSubFrame` — manage its visibility manually and restore it on every Blizzard tab click.
6. Comparison mode replaces the `AchievementFrameTab_OnClick` alias — hook the two named functions, not the alias.
7. Taint: `Secure: 1` on the Blizzard addon; use hooksecurefunc only, never overwrite Blizzard functions, never taint `AchievementFrame.selectedTab` beyond PanelTemplates' own writes (PanelTemplates_Tab_OnClick does that write; it's the same path Blizzard uses, and Krowi's addon proves the pattern is tolerated).
8. Exclude Feats of Strength (cat 81 + children) by default; toggle to include.
9. Refresh on `ACHIEVEMENT_EARNED`; also handle `CRITERIA_UPDATE` only for the selected/expanded row (Blizzard pattern, lua:907-915) to avoid rescanning 5k achievements on every criteria tick. **Never full-rescan on CRITERIA_UPDATE — it fires constantly.**
10. Guild achievements: out of scope v1 (Remaining tab shows player achievements only).
11. Test with `/console scriptErrors 1` and BugSack/BugGrabber.

## 5. Suggested verification checklist (in-game)

- [ ] Y opens UI; 4th tab "Remaining" renders with native art; resize/tab-switch cycles cleanly 1→4→2→4→3→4.
- [ ] List shows only incomplete; spot-check 3 known-complete achievements are absent; a known-incomplete progressive chain shows only its current step.
- [ ] Click row expands objectives; shift-click links in chat; expand → switch to tab 1 → back → no orphaned objectives frame.
- [ ] Hide an achievement → gone; "Show hidden" reveals; restore works; `/reload` persists both.
- [ ] Earn an achievement (e.g. a cheap exploration one) with tab open → row disappears, no error.
- [ ] Export dialog: paste into a spreadsheet, columns intact, quotes/commas in descriptions survive.
- [ ] Open comparison (inspect another player's achievements) → our tab hidden; close → tab back.
- [ ] No errors at login with only this addon + BugSack enabled; achievement toast click-through still opens correct category.

## 6. Open questions for the user (don't block on these)

- CSV template (they'll provide; guess per §1.3 meanwhile).
- Tab label ("Remaining"? "To Do"?) and whether hidden = "Untracked" wording.
- Account-wide vs this-character completion semantics (default: account-wide `completed`).
- Include Feats of Strength by default? (default: no)
