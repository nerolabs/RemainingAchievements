-- itIT (machine translation). Missing keys fall back to enUS via RA.L.
local ADDON_NAME, RA = ...;
if GetLocale() ~= "itIT" then return end
local L = RA.L;

L["Remaining"] = "Rimanenti";
L["%s remaining"] = "%s rimanenti";
L["%s points unearned"] = "%s punti non ottenuti";
L["(hidden)"] = "(nascosto)";

L["Include Feats of Strength |cffff7f00(beta)|r"] = "Includi le imprese |cffff7f00(beta)|r";
L["Include hidden achievements"] = "Includi le imprese nascoste";
L["Include opposite faction"] = "Includi la fazione opposta";
L["Show stashed for later (%d)"] = "Mostra quelle messe da parte (%d)";

L["Feats of Strength"] = "Imprese";
L["Obtainable Feats of Strength for your faction, including known hidden ones. Retired content is filtered out: promotions, old PvP titles, one-time world events, realm firsts, and past-season feats. Beta: the game has no obtainability data, so report anything that slips through."] = "Imprese ottenibili per la tua fazione, incluse quelle nascoste note. I contenuti ritirati vengono filtrati: promozioni, vecchi titoli PvP, eventi mondiali unici, primati del reame e imprese delle stagioni passate. Beta: il gioco non fornisce dati sull'ottenibilità, quindi segnala tutto ciò che sfugge.";
L["Hidden achievements"] = "Imprese nascoste";
L["True hidden achievements: point-earning achievements Blizzard hides from the UI until they are earned. Feats of Strength are not included here - they have their own toggle below. May occasionally list one that is no longer obtainable - please report any you spot."] = "Vere imprese nascoste: imprese che assegnano punti e che Blizzard nasconde dall'interfaccia finché non vengono ottenute. Le imprese di forza non sono incluse qui: hanno un'opzione dedicata più sotto. Occasionalmente potrebbe comparirne una non più ottenibile: segnala quelle che noti.";
L["Stashed for later"] = "Messe da parte";
L["Use a row's X button or right-click menu to stash achievements you want to set aside, removing them from the Remaining list and its counts. This toggle shows them again with one-click restore. Stashing persists account-wide."] = "Usa il pulsante X di una riga o il menu del clic destro per mettere da parte le imprese che vuoi accantonare; vengono rimosse dalla lista Rimanenti e dai suoi conteggi. Questa opzione le mostra di nuovo con ripristino in un clic. Le imprese messe da parte restano valide sull'intero account.";
L["Opposite-faction achievements"] = "Imprese della fazione opposta";
L["Achievements only the other faction can still earn, DataForAzeroth-style. Uses the Remaining list recorded when a character of that faction opens this tab."] = "Imprese che solo l'altra fazione può ancora ottenere, in stile DataForAzeroth. Usa la lista Rimanenti registrata quando un personaggio di quella fazione apre questa scheda.";
L["Opposite-faction totals"] = "Totali della fazione opposta";
L["These factional points count towards totals on DataForAzeroth."] = "Questi punti di fazione contano per i totali su DataForAzeroth.";

L["Using the %s list from %s, recorded %s (%s)."] = "Uso della lista %s di %s, registrata il %s (%s).";
L["Log into a %s character and open the Remaining tab to refresh it."] = "Accedi con un personaggio %s e apri la scheda Rimanenti per aggiornarla.";
L["No %s data yet: log into a %s character and open the Remaining tab once."] = "Ancora nessun dato %s: accedi con un personaggio %s e apri una volta la scheda Rimanenti.";
L["Not available on neutral characters."] = "Non disponibile per i personaggi neutrali.";
L["today"] = "oggi";
L["yesterday"] = "ieri";
L["%d days ago"] = "%d giorni fa";

L["Stash for later"] = "Metti da parte";
L["Return to the Remaining list"] = "Torna alla lista Rimanenti";
L["Return to list"] = "Torna alla lista";
L["Track on HUD"] = "Traccia sull'HUD";
L["Untrack on HUD"] = "Smetti di tracciare sull'HUD";
L["Link to chat"] = "Collega alla chat";

L["Export Spreadsheet"] = "Esporta foglio di calcolo";
L["Updating..."] = "Aggiornamento...";

L["Remaining Achievements - Spreadsheet Export"] = "Imprese rimanenti – Esportazione foglio di calcolo";
L["Remaining Achievements - Export (%d rows)"] = "Imprese rimanenti – Esportazione (%d righe)";
L["Press %s+C to copy, then paste directly into Google Sheets or Excel."] = "Premi %s+C per copiare, poi incolla direttamente in Google Sheets o Excel.";
L["Press %s+C to copy, then paste into your report."] = "Premi %s+C per copiare, poi incolla nel tuo report.";
L["Search filter active - exporting only the rows currently shown."] = "Filtro di ricerca attivo – vengono esportate solo le righe attualmente mostrate.";
