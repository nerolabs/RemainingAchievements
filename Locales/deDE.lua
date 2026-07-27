-- deDE (machine translation). Missing keys fall back to enUS via RA.L.
local ADDON_NAME, RA = ...;
if GetLocale() ~= "deDE" then return end
local L = RA.L;

L["Remaining"] = "Verbleibend";
L["%s remaining"] = "%s verbleibend";
L["%s points unearned"] = "%s Punkte ausstehend";
L["(hidden)"] = "(versteckt)";

L["Include Feats of Strength |cffff7f00(beta)|r"] = "Heldentaten einschließen |cffff7f00(Beta)|r";
L["Include hidden achievements"] = "Versteckte Erfolge einschließen";
L["Include opposite faction"] = "Gegnerische Fraktion einschließen";
L["Show stashed for later (%d)"] = "Zurückgestellte anzeigen (%d)";

L["Feats of Strength"] = "Heldentaten";
L["Obtainable Feats of Strength for your faction, including known hidden ones. Retired content is filtered out: promotions, old PvP titles, one-time world events, realm firsts, and past-season feats. Beta: the game has no obtainability data, so report anything that slips through."] = "Erreichbare Heldentaten für deine Fraktion, einschließlich bekannter versteckter. Eingestellte Inhalte werden herausgefiltert: Beförderungen, alte PvP-Titel, einmalige Weltereignisse, Ersterfolge des Servers und Heldentaten vergangener Saisons. Beta: Das Spiel liefert keine Daten zur Erreichbarkeit, melde also alles, was durchrutscht.";
L["Hidden achievements"] = "Versteckte Erfolge";
L["True hidden achievements: point-earning achievements Blizzard hides from the UI until they are earned. Feats of Strength are not included here - they have their own toggle below. May occasionally list one that is no longer obtainable - please report any you spot."] = "Echte versteckte Erfolge: Punkte gebende Erfolge, die Blizzard bis zum Erhalt in der Oberfläche verbirgt. Heldentaten sind hier nicht enthalten – sie haben ihre eigene Option weiter unten. Gelegentlich wird einer angezeigt, der nicht mehr erreichbar ist – bitte melde solche Fälle.";
L["Stashed for later"] = "Für später zurückgestellt";
L["Use a row's X button or right-click menu to stash achievements you want to set aside, removing them from the Remaining list and its counts. This toggle shows them again with one-click restore. Stashing persists account-wide."] = "Nutze den X-Knopf einer Zeile oder das Rechtsklickmenü, um Erfolge zurückzustellen, die du beiseitelegen möchtest; sie werden aus der Verbleibend-Liste und ihren Zählungen entfernt. Diese Option zeigt sie wieder an, mit Wiederherstellung per Klick. Das Zurückstellen gilt accountweit.";
L["Opposite-faction achievements"] = "Erfolge der gegnerischen Fraktion";
L["Achievements only the other faction can still earn, DataForAzeroth-style. Uses the Remaining list recorded when a character of that faction opens this tab."] = "Erfolge, die nur die andere Fraktion noch erhalten kann, im Stil von DataForAzeroth. Verwendet die Verbleibend-Liste, die aufgezeichnet wird, wenn ein Charakter dieser Fraktion diesen Tab öffnet.";
L["Opposite-faction totals"] = "Gesamtwerte der gegnerischen Fraktion";
L["These factional points count towards totals on DataForAzeroth."] = "Diese Fraktionspunkte zählen zu den Gesamtwerten auf DataForAzeroth.";

L["Using the %s list from %s, recorded %s (%s)."] = "Verwende die %s-Liste von %s, aufgezeichnet am %s (%s).";
L["Log into a %s character and open the Remaining tab to refresh it."] = "Melde dich mit einem %s-Charakter an und öffne den Tab „Verbleibend“, um sie zu aktualisieren.";
L["No %s data yet: log into a %s character and open the Remaining tab once."] = "Noch keine %s-Daten: Melde dich mit einem %s-Charakter an und öffne einmal den Tab „Verbleibend“.";
L["Not available on neutral characters."] = "Nicht verfügbar für neutrale Charaktere.";
L["today"] = "heute";
L["yesterday"] = "gestern";
L["%d days ago"] = "vor %d Tagen";

L["Stash for later"] = "Für später zurückstellen";
L["Return to the Remaining list"] = "Zurück zur Verbleibend-Liste";
L["Return to list"] = "Zurück zur Liste";
L["Track on HUD"] = "Auf HUD verfolgen";
L["Untrack on HUD"] = "HUD-Verfolgung beenden";
L["Link to chat"] = "Im Chat verlinken";

L["Export Spreadsheet"] = "Tabelle exportieren";
L["Updating..."] = "Aktualisiere ...";

L["Remaining Achievements - Spreadsheet Export"] = "Verbleibende Erfolge – Tabellenexport";
L["Remaining Achievements - Export (%d rows)"] = "Verbleibende Erfolge – Export (%d Zeilen)";
L["Press %s+C to copy, then paste directly into Google Sheets or Excel."] = "Drücke %s+C zum Kopieren und füge es direkt in Google Sheets oder Excel ein.";
L["Press %s+C to copy, then paste into your report."] = "Drücke %s+C zum Kopieren und füge es in deinen Bericht ein.";
L["Search filter active - exporting only the rows currently shown."] = "Suchfilter aktiv – es werden nur die aktuell angezeigten Zeilen exportiert.";
