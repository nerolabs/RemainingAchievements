-- zhTW (machine translation). Missing keys fall back to enUS via RA.L.
local ADDON_NAME, RA = ...;
if GetLocale() ~= "zhTW" then return end
local L = RA.L;

L["Remaining"] = "未完成";
L["%s remaining"] = "剩餘 %s 項";
L["%s points unearned"] = "未取得 %s 點";
L["(hidden)"] = "（隱藏）";

L["Include Feats of Strength |cffff7f00(beta)|r"] = "包含武勇事蹟 |cffff7f00（測試版）|r";
L["Include hidden achievements"] = "包含隱藏成就";
L["Include opposite faction"] = "包含敵對陣營";
L["Show stashed for later (%d)"] = "顯示暫存的項目（%d）";

L["Feats of Strength"] = "武勇事蹟";
L["Obtainable Feats of Strength for your faction, including known hidden ones. Retired content is filtered out: promotions, old PvP titles, one-time world events, realm firsts, and past-season feats. Beta: the game has no obtainability data, so report anything that slips through."] = "你所屬陣營可取得的武勇事蹟，包括已知的隱藏項目。已停用的內容會被篩除：促銷活動、舊的PvP頭銜、一次性的世界事件、伺服器首殺，以及過往賽季的事蹟。測試版：遊戲未提供可取得性資料，若有漏網項目請回報。";
L["Hidden achievements"] = "隱藏成就";
L["True hidden achievements: point-earning achievements Blizzard hides from the UI until they are earned. Feats of Strength are not included here - they have their own toggle below. May occasionally list one that is no longer obtainable - please report any you spot."] = "真正的隱藏成就：在取得之前被暴雪從介面中隱藏的、可獲得點數的成就。此處不包含武勇事蹟——它們在下方有獨立選項。偶爾可能會列出已無法取得的項目，若有發現請回報。";
L["Stashed for later"] = "已暫存";
L["Use a row's X button or right-click menu to stash achievements you want to set aside, removing them from the Remaining list and its counts. This toggle shows them again with one-click restore. Stashing persists account-wide."] = "使用某一列的X按鈕或右鍵選單，暫存你想擱置的成就；它們會從未完成列表及其計數中移除。開啟此選項可再次顯示它們，並可一鍵還原。暫存會在整個帳號範圍內保留。";
L["Opposite-faction achievements"] = "敵對陣營成就";
L["Achievements only the other faction can still earn, DataForAzeroth-style. Uses the Remaining list recorded when a character of that faction opens this tab."] = "只有敵對陣營還能取得的成就，採用DataForAzeroth的方式。使用該陣營角色開啟此頁籤時記錄的未完成列表。";
L["Opposite-faction totals"] = "敵對陣營合計";
L["These factional points count towards totals on DataForAzeroth."] = "這些陣營點數會計入DataForAzeroth上的總計。";

L["Using the %s list from %s, recorded %s (%s)."] = "正在使用%s的列表，來自%s，記錄於%s（%s）。";
L["Log into a %s character and open the Remaining tab to refresh it."] = "登入一個%s角色並開啟未完成頁籤即可更新。";
L["No %s data yet: log into a %s character and open the Remaining tab once."] = "尚無%s的資料：請登入一個%s角色並開啟一次未完成頁籤。";
L["Not available on neutral characters."] = "中立角色無法使用。";
L["today"] = "今天";
L["yesterday"] = "昨天";
L["%d days ago"] = "%d天前";

L["Stash for later"] = "暫存";
L["Return to the Remaining list"] = "移回未完成列表";
L["Return to list"] = "移回列表";
L["Track on HUD"] = "在HUD上追蹤";
L["Untrack on HUD"] = "取消HUD追蹤";
L["Link to chat"] = "連結到聊天";

L["Export Spreadsheet"] = "匯出表格";
L["Updating..."] = "更新中……";

L["Remaining Achievements - Spreadsheet Export"] = "未完成成就 - 表格匯出";
L["Remaining Achievements - Export (%d rows)"] = "未完成成就 - 匯出（%d 列）";
L["Press %s+C to copy, then paste directly into Google Sheets or Excel."] = "按%s+C複製，然後直接貼到Google Sheets或Excel中。";
L["Press %s+C to copy, then paste into your report."] = "按%s+C複製，然後貼到你的報告中。";
L["Search filter active - exporting only the rows currently shown."] = "搜尋篩選已啟用——僅匯出目前顯示的列。";
