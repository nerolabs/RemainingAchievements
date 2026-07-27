-- koKR (machine translation). Missing keys fall back to enUS via RA.L.
local ADDON_NAME, RA = ...;
if GetLocale() ~= "koKR" then return end
local L = RA.L;

L["Remaining"] = "남은 항목";
L["%s remaining"] = "%s개 남음";
L["%s points unearned"] = "미획득 점수 %s";
L["(hidden)"] = "(숨김)";

L["Include Feats of Strength |cffff7f00(beta)|r"] = "위업 포함 |cffff7f00(베타)|r";
L["Include hidden achievements"] = "숨겨진 업적 포함";
L["Include opposite faction"] = "반대 진영 포함";
L["Show stashed for later (%d)"] = "나중을 위해 보관한 항목 표시 (%d)";

L["Feats of Strength"] = "위업";
L["Obtainable Feats of Strength for your faction, including known hidden ones. Retired content is filtered out: promotions, old PvP titles, one-time world events, realm firsts, and past-season feats. Beta: the game has no obtainability data, so report anything that slips through."] = "알려진 숨겨진 위업을 포함하여 현재 진영에서 획득 가능한 위업입니다. 중단된 콘텐츠는 걸러집니다: 프로모션, 예전 PvP 칭호, 일회성 월드 이벤트, 서버 최초, 지난 시즌 위업. 베타: 게임에 획득 가능 여부 데이터가 없으므로 빠져나온 항목이 있으면 제보해 주세요.";
L["Hidden achievements"] = "숨겨진 업적";
L["True hidden achievements: point-earning achievements Blizzard hides from the UI until they are earned. Feats of Strength are not included here - they have their own toggle below. May occasionally list one that is no longer obtainable - please report any you spot."] = "진짜 숨겨진 업적: 획득 전까지 블리자드가 UI에서 숨기는, 점수를 주는 업적입니다. 위업은 여기에 포함되지 않으며 아래에 별도 옵션이 있습니다. 간혹 더 이상 획득할 수 없는 항목이 표시될 수 있으니 발견하면 제보해 주세요.";
L["Stashed for later"] = "나중을 위해 보관함";
L["Use a row's X button or right-click menu to stash achievements you want to set aside, removing them from the Remaining list and its counts. This toggle shows them again with one-click restore. Stashing persists account-wide."] = "따로 치워두고 싶은 업적은 각 줄의 X 버튼이나 우클릭 메뉴로 보관하세요. 남은 항목 목록과 그 집계에서 제거됩니다. 이 옵션을 켜면 다시 표시되며 한 번의 클릭으로 복원할 수 있습니다. 보관은 계정 전체에 유지됩니다.";
L["Opposite-faction achievements"] = "반대 진영 업적";
L["Achievements only the other faction can still earn, DataForAzeroth-style. Uses the Remaining list recorded when a character of that faction opens this tab."] = "DataForAzeroth 방식으로, 다른 진영만 아직 획득할 수 있는 업적입니다. 해당 진영의 캐릭터가 이 탭을 열 때 기록된 남은 항목 목록을 사용합니다.";
L["Opposite-faction totals"] = "반대 진영 합계";
L["These factional points count towards totals on DataForAzeroth."] = "이 진영 점수는 DataForAzeroth의 합계에 포함됩니다.";

L["Using the %s list from %s, recorded %s (%s)."] = "%s 진영 목록 사용 중 (%s, %s 기록) (%s).";
L["Log into a %s character and open the Remaining tab to refresh it."] = "%s 진영 캐릭터로 접속하여 남은 항목 탭을 열면 갱신됩니다.";
L["No %s data yet: log into a %s character and open the Remaining tab once."] = "%s 진영 데이터가 아직 없습니다: %s 진영 캐릭터로 접속하여 남은 항목 탭을 한 번 열어 주세요.";
L["Not available on neutral characters."] = "중립 캐릭터에서는 사용할 수 없습니다.";
L["today"] = "오늘";
L["yesterday"] = "어제";
L["%d days ago"] = "%d일 전";

L["Stash for later"] = "나중을 위해 보관";
L["Return to the Remaining list"] = "남은 항목 목록으로 되돌리기";
L["Return to list"] = "목록으로 되돌리기";
L["Track on HUD"] = "HUD에서 추적";
L["Untrack on HUD"] = "HUD 추적 해제";
L["Link to chat"] = "대화에 연결";

L["Export Spreadsheet"] = "스프레드시트 내보내기";
L["Updating..."] = "갱신 중...";

L["Remaining Achievements - Spreadsheet Export"] = "남은 업적 - 스프레드시트 내보내기";
L["Remaining Achievements - Export (%d rows)"] = "남은 업적 - 내보내기 (%d행)";
L["Press %s+C to copy, then paste directly into Google Sheets or Excel."] = "%s+C를 눌러 복사한 뒤 Google Sheets나 Excel에 바로 붙여넣으세요.";
L["Press %s+C to copy, then paste into your report."] = "%s+C를 눌러 복사한 뒤 보고서에 붙여넣으세요.";
L["Search filter active - exporting only the rows currently shown."] = "검색 필터 활성화됨 - 현재 표시된 행만 내보냅니다.";
