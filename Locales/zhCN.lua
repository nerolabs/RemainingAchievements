-- zhCN (machine translation). Missing keys fall back to enUS via RA.L.
local ADDON_NAME, RA = ...;
if GetLocale() ~= "zhCN" then return end
local L = RA.L;

L["Remaining"] = "未完成";
L["%s remaining"] = "剩余 %s 项";
L["%s points unearned"] = "未获得 %s 点";
L["(hidden)"] = "（隐藏）";

L["Include Feats of Strength |cffff7f00(beta)|r"] = "包含武勇事迹 |cffff7f00（测试版）|r";
L["Include hidden achievements"] = "包含隐藏成就";
L["Include opposite faction"] = "包含对立阵营";
L["Show stashed for later (%d)"] = "显示暂存的项目（%d）";

L["Feats of Strength"] = "武勇事迹";
L["Obtainable Feats of Strength for your faction, including known hidden ones. Retired content is filtered out: promotions, old PvP titles, one-time world events, realm firsts, and past-season feats. Beta: the game has no obtainability data, so report anything that slips through."] = "你所在阵营可获得的武勇事迹，包括已知的隐藏项。已停用的内容会被过滤：推广活动、旧的PvP头衔、一次性的世界事件、服务器首杀，以及往季的事迹。测试版：游戏未提供可获得性数据，如有遗漏项目请反馈。";
L["Hidden achievements"] = "隐藏成就";
L["True hidden achievements: point-earning achievements Blizzard hides from the UI until they are earned. Feats of Strength are not included here - they have their own toggle below. May occasionally list one that is no longer obtainable - please report any you spot."] = "真正的隐藏成就：暴雪在获得之前从界面中隐藏的、可获得点数的成就。此处不包含武勇事迹——它们在下方有单独的选项。偶尔可能会列出已无法获得的项目，如有发现请反馈。";
L["Stashed for later"] = "已暂存";
L["Use a row's X button or right-click menu to stash achievements you want to set aside, removing them from the Remaining list and its counts. This toggle shows them again with one-click restore. Stashing persists account-wide."] = "使用某一行的X按钮或右键菜单，暂存你想搁置的成就；它们会从未完成列表及其计数中移除。开启此选项可再次显示它们，并可一键恢复。暂存在整个账号范围内保留。";
L["Opposite-faction achievements"] = "对立阵营成就";
L["Achievements only the other faction can still earn, DataForAzeroth-style. Uses the Remaining list recorded when a character of that faction opens this tab."] = "只有对立阵营还能获得的成就，采用DataForAzeroth的方式。使用该阵营角色打开此标签页时记录的未完成列表。";
L["Opposite-faction totals"] = "对立阵营合计";
L["These factional points count towards totals on DataForAzeroth."] = "这些阵营点数计入DataForAzeroth上的总计。";

L["Using the %s list from %s, recorded %s (%s)."] = "正在使用%s的列表，来自%s，记录于%s（%s）。";
L["Log into a %s character and open the Remaining tab to refresh it."] = "登录一个%s角色并打开未完成标签页即可刷新。";
L["No %s data yet: log into a %s character and open the Remaining tab once."] = "暂无%s的数据：请登录一个%s角色并打开一次未完成标签页。";
L["Not available on neutral characters."] = "中立角色无法使用。";
L["today"] = "今天";
L["yesterday"] = "昨天";
L["%d days ago"] = "%d天前";

L["Stash for later"] = "暂存";
L["Return to the Remaining list"] = "移回未完成列表";
L["Return to list"] = "移回列表";
L["Track on HUD"] = "在HUD上追踪";
L["Untrack on HUD"] = "取消HUD追踪";
L["Link to chat"] = "链接到聊天";

L["Export Spreadsheet"] = "导出表格";
L["Updating..."] = "更新中……";

L["Remaining Achievements - Spreadsheet Export"] = "未完成成就 - 表格导出";
L["Remaining Achievements - Export (%d rows)"] = "未完成成就 - 导出（%d 行）";
L["Press %s+C to copy, then paste directly into Google Sheets or Excel."] = "按%s+C复制，然后直接粘贴到Google Sheets或Excel中。";
L["Press %s+C to copy, then paste into your report."] = "按%s+C复制，然后粘贴到你的报告中。";
L["Search filter active - exporting only the rows currently shown."] = "搜索筛选已启用——仅导出当前显示的行。";
