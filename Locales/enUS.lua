-- enUS is the source locale and the canonical key list. RA.L falls back to the
-- key itself for any string a locale is missing, so translations can be partial
-- and untranslated strings simply render in English.
--
-- Keys are the English text (AceLocale style): readable at the call site, and
-- format specifiers (%s/%d) are kept inside the string so translators can
-- reorder them for their grammar. Diagnostic output (/radiagnose, /raseason)
-- and the TSV export column headers are intentionally NOT localized -- the
-- former is for English bug reports, the latter is a data contract.
local ADDON_NAME, RA = ...;

local L = setmetatable({}, { __index = function(_, k) return k; end });
RA.L = L;

-- Tab and count header
L["Remaining"] = "Remaining";
L["%s remaining"] = "%s remaining";
L["%s points unearned"] = "%s points unearned";
L["(+%s %s)"] = "(+%s %s)"; -- opposite-faction suffix: count/points, faction name
L["(hidden)"] = "(hidden)";

-- Toggles (labels)
L["Include Feats of Strength |cffff7f00(beta)|r"] = "Include Feats of Strength |cffff7f00(beta)|r";
L["Include hidden achievements"] = "Include hidden achievements";
L["Include opposite faction"] = "Include opposite faction";
L["Show stashed for later (%d)"] = "Show stashed for later (%d)";

-- Toggle tooltips (title + body)
L["Feats of Strength"] = "Feats of Strength";
L["Obtainable Feats of Strength for your faction, including known hidden ones. Retired content is filtered out: promotions, old PvP titles, one-time world events, realm firsts, and past-season feats. Beta: the game has no obtainability data, so report anything that slips through."] = "Obtainable Feats of Strength for your faction, including known hidden ones. Retired content is filtered out: promotions, old PvP titles, one-time world events, realm firsts, and past-season feats. Beta: the game has no obtainability data, so report anything that slips through.";
L["Hidden achievements"] = "Hidden achievements";
L["True hidden achievements: point-earning achievements Blizzard hides from the UI until they are earned. Feats of Strength are not included here - they have their own toggle below. May occasionally list one that is no longer obtainable - please report any you spot."] = "True hidden achievements: point-earning achievements Blizzard hides from the UI until they are earned. Feats of Strength are not included here - they have their own toggle below. May occasionally list one that is no longer obtainable - please report any you spot.";
L["Stashed for later"] = "Stashed for later";
L["Use a row's X button or right-click menu to stash achievements you want to set aside, removing them from the Remaining list and its counts. This toggle shows them again with one-click restore. Stashing persists account-wide."] = "Use a row's X button or right-click menu to stash achievements you want to set aside, removing them from the Remaining list and its counts. This toggle shows them again with one-click restore. Stashing persists account-wide.";
L["Opposite-faction achievements"] = "Opposite-faction achievements";
L["Achievements only the other faction can still earn, DataForAzeroth-style. Uses the Remaining list recorded when a character of that faction opens this tab."] = "Achievements only the other faction can still earn, DataForAzeroth-style. Uses the Remaining list recorded when a character of that faction opens this tab.";
L["Opposite-faction totals"] = "Opposite-faction totals";
L["These factional points count towards totals on DataForAzeroth."] = "These factional points count towards totals on DataForAzeroth.";

-- Opposite-faction snapshot status lines
L["Using the %s list from %s, recorded %s (%s)."] = "Using the %s list from %s, recorded %s (%s).";
L["Log into a %s character and open the Remaining tab to refresh it."] = "Log into a %s character and open the Remaining tab to refresh it.";
L["No %s data yet: log into a %s character and open the Remaining tab once."] = "No %s data yet: log into a %s character and open the Remaining tab once.";
L["Not available on neutral characters."] = "Not available on neutral characters.";
L["today"] = "today";
L["yesterday"] = "yesterday";
L["%d days ago"] = "%d days ago";

-- Row context menu + stash button
L["Stash for later"] = "Stash for later";
L["Return to the Remaining list"] = "Return to the Remaining list";
L["Return to list"] = "Return to list";
L["Track on HUD"] = "Track on HUD";
L["Untrack on HUD"] = "Untrack on HUD";
L["Link to chat"] = "Link to chat";

-- Misc
L["Export Spreadsheet"] = "Export Spreadsheet";
L["Updating..."] = "Updating...";

-- Export dialog chrome (TSV column headers stay English -- see note above)
L["Remaining Achievements - Spreadsheet Export"] = "Remaining Achievements - Spreadsheet Export";
L["Remaining Achievements - Export (%d rows)"] = "Remaining Achievements - Export (%d rows)";
L["Press %s+C to copy, then paste directly into Google Sheets or Excel."] = "Press %s+C to copy, then paste directly into Google Sheets or Excel.";
L["Press %s+C to copy, then paste into your report."] = "Press %s+C to copy, then paste into your report.";
L["Search filter active - exporting only the rows currently shown."] = "Search filter active - exporting only the rows currently shown.";
