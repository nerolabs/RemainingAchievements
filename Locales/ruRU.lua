-- ruRU (machine translation). Missing keys fall back to enUS via RA.L.
local ADDON_NAME, RA = ...;
if GetLocale() ~= "ruRU" then return end
local L = RA.L;

L["Remaining"] = "Оставшиеся";
L["%s remaining"] = "Осталось: %s";
L["%s points unearned"] = "Очков не получено: %s";
L["(hidden)"] = "(скрытое)";

L["Include Feats of Strength |cffff7f00(beta)|r"] = "Включить памятные достижения |cffff7f00(бета)|r";
L["Include hidden achievements"] = "Включить скрытые достижения";
L["Include opposite faction"] = "Включить противоположную фракцию";
L["Show stashed for later (%d)"] = "Показать отложенные (%d)";

L["Feats of Strength"] = "Памятные достижения";
L["Obtainable Feats of Strength for your faction, including known hidden ones. Retired content is filtered out: promotions, old PvP titles, one-time world events, realm firsts, and past-season feats. Beta: the game has no obtainability data, so report anything that slips through."] = "Доступные памятные достижения для вашей фракции, включая известные скрытые. Отключенный контент отфильтрован: акции, старые PvP-звания, разовые игровые события, первые на сервере и достижения прошлых сезонов. Бета: игра не предоставляет данных о доступности, поэтому сообщайте обо всём, что просочилось.";
L["Hidden achievements"] = "Скрытые достижения";
L["True hidden achievements: point-earning achievements Blizzard hides from the UI until they are earned. Feats of Strength are not included here - they have their own toggle below. May occasionally list one that is no longer obtainable - please report any you spot."] = "Настоящие скрытые достижения: приносящие очки достижения, которые Blizzard скрывает из интерфейса до их получения. Памятные достижения сюда не входят — у них есть отдельная опция ниже. Изредка может отображаться недоступное достижение — пожалуйста, сообщайте о замеченных.";
L["Stashed for later"] = "Отложено на потом";
L["Use a row's X button or right-click menu to stash achievements you want to set aside, removing them from the Remaining list and its counts. This toggle shows them again with one-click restore. Stashing persists account-wide."] = "Используйте кнопку X в строке или меню правого клика, чтобы отложить достижения, которые хотите убрать; они исчезнут из списка «Оставшиеся» и его счётчиков. Эта опция снова показывает их с восстановлением в один клик. Отложенное сохраняется для всей учётной записи.";
L["Opposite-faction achievements"] = "Достижения противоположной фракции";
L["Achievements only the other faction can still earn, DataForAzeroth-style. Uses the Remaining list recorded when a character of that faction opens this tab."] = "Достижения, которые может получить только другая фракция, в стиле DataForAzeroth. Использует список «Оставшиеся», записанный, когда персонаж этой фракции открывает эту вкладку.";
L["Opposite-faction totals"] = "Итоги противоположной фракции";
L["These factional points count towards totals on DataForAzeroth."] = "Эти фракционные очки учитываются в итогах на DataForAzeroth.";

L["Using the %s list from %s, recorded %s (%s)."] = "Используется список фракции %s от %s, записан %s (%s).";
L["Log into a %s character and open the Remaining tab to refresh it."] = "Войдите за персонажа фракции %s и откройте вкладку «Оставшиеся», чтобы обновить его.";
L["No %s data yet: log into a %s character and open the Remaining tab once."] = "Данных фракции %s пока нет: войдите за персонажа фракции %s и один раз откройте вкладку «Оставшиеся».";
L["Not available on neutral characters."] = "Недоступно для нейтральных персонажей.";
L["today"] = "сегодня";
L["yesterday"] = "вчера";
L["%d days ago"] = "%d дн. назад";

L["Stash for later"] = "Отложить на потом";
L["Return to the Remaining list"] = "Вернуть в список «Оставшиеся»";
L["Return to list"] = "Вернуть в список";
L["Track on HUD"] = "Отслеживать на экране";
L["Untrack on HUD"] = "Прекратить отслеживание";
L["Link to chat"] = "Ссылка в чат";

L["Export Spreadsheet"] = "Экспорт таблицы";
L["Updating..."] = "Обновление...";

L["Remaining Achievements - Spreadsheet Export"] = "Оставшиеся достижения — экспорт таблицы";
L["Remaining Achievements - Export (%d rows)"] = "Оставшиеся достижения — экспорт (строк: %d)";
L["Press %s+C to copy, then paste directly into Google Sheets or Excel."] = "Нажмите %s+C, чтобы скопировать, затем вставьте прямо в Google Sheets или Excel.";
L["Press %s+C to copy, then paste into your report."] = "Нажмите %s+C, чтобы скопировать, затем вставьте в свой отчёт.";
L["Search filter active - exporting only the rows currently shown."] = "Активен фильтр поиска — экспортируются только показанные сейчас строки.";
