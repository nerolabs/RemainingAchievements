-- frFR (machine translation). Missing keys fall back to enUS via RA.L.
local ADDON_NAME, RA = ...;
if GetLocale() ~= "frFR" then return end
local L = RA.L;

L["Remaining"] = "Restants";
L["%s remaining"] = "%s restants";
L["%s points unearned"] = "%s points non obtenus";
L["(hidden)"] = "(caché)";

L["Include Feats of Strength |cffff7f00(beta)|r"] = "Inclure les hauts faits d'éclat |cffff7f00(bêta)|r";
L["Include hidden achievements"] = "Inclure les hauts faits cachés";
L["Include opposite faction"] = "Inclure la faction adverse";
L["Show stashed for later (%d)"] = "Afficher les hauts faits mis de côté (%d)";

L["Feats of Strength"] = "Hauts faits d'éclat";
L["Obtainable Feats of Strength for your faction, including known hidden ones. Retired content is filtered out: promotions, old PvP titles, one-time world events, realm firsts, and past-season feats. Beta: the game has no obtainability data, so report anything that slips through."] = "Hauts faits d'éclat accessibles pour votre faction, y compris ceux cachés connus. Le contenu retiré est filtré : promotions, anciens titres JcJ, événements mondiaux uniques, premières du royaume et hauts faits des saisons passées. Bêta : le jeu ne fournit aucune donnée d'accessibilité, alors signalez tout ce qui passe au travers.";
L["Hidden achievements"] = "Hauts faits cachés";
L["True hidden achievements: point-earning achievements Blizzard hides from the UI until they are earned. Feats of Strength are not included here - they have their own toggle below. May occasionally list one that is no longer obtainable - please report any you spot."] = "Véritables hauts faits cachés : des hauts faits rapportant des points que Blizzard masque dans l'interface jusqu'à leur obtention. Les hauts faits d'éclat ne sont pas inclus ici : ils ont leur propre option ci-dessous. Il peut arriver qu'un haut fait devenu inaccessible apparaisse : merci de signaler ceux que vous repérez.";
L["Stashed for later"] = "Mis de côté";
L["Use a row's X button or right-click menu to stash achievements you want to set aside, removing them from the Remaining list and its counts. This toggle shows them again with one-click restore. Stashing persists account-wide."] = "Utilisez le bouton X d'une ligne ou le menu clic droit pour mettre de côté les hauts faits que vous souhaitez écarter ; ils sont retirés de la liste des Restants et de ses compteurs. Cette option les réaffiche avec une restauration en un clic. La mise de côté est conservée sur tout le compte.";
L["Opposite-faction achievements"] = "Hauts faits de la faction adverse";
L["Achievements only the other faction can still earn, DataForAzeroth-style. Uses the Remaining list recorded when a character of that faction opens this tab."] = "Hauts faits que seule l'autre faction peut encore obtenir, à la manière de DataForAzeroth. Utilise la liste des Restants enregistrée lorsqu'un personnage de cette faction ouvre cet onglet.";
L["Opposite-faction totals"] = "Totaux de la faction adverse";
L["These factional points count towards totals on DataForAzeroth."] = "Ces points de faction comptent dans les totaux sur DataForAzeroth.";

L["Using the %s list from %s, recorded %s (%s)."] = "Utilisation de la liste %s de %s, enregistrée le %s (%s).";
L["Log into a %s character and open the Remaining tab to refresh it."] = "Connectez-vous avec un personnage %s et ouvrez l'onglet Restants pour l'actualiser.";
L["No %s data yet: log into a %s character and open the Remaining tab once."] = "Aucune donnée %s pour l'instant : connectez-vous avec un personnage %s et ouvrez une fois l'onglet Restants.";
L["Not available on neutral characters."] = "Non disponible pour les personnages neutres.";
L["today"] = "aujourd'hui";
L["yesterday"] = "hier";
L["%d days ago"] = "il y a %d jours";

L["Stash for later"] = "Mettre de côté";
L["Return to the Remaining list"] = "Revenir à la liste des Restants";
L["Return to list"] = "Revenir à la liste";
L["Track on HUD"] = "Suivre sur l'ATH";
L["Untrack on HUD"] = "Ne plus suivre sur l'ATH";
L["Link to chat"] = "Lier dans la discussion";

L["Export Spreadsheet"] = "Exporter le tableur";
L["Updating..."] = "Mise à jour...";

L["Remaining Achievements - Spreadsheet Export"] = "Hauts faits restants – Export de tableur";
L["Remaining Achievements - Export (%d rows)"] = "Hauts faits restants – Export (%d lignes)";
L["Press %s+C to copy, then paste directly into Google Sheets or Excel."] = "Appuyez sur %s+C pour copier, puis collez directement dans Google Sheets ou Excel.";
L["Press %s+C to copy, then paste into your report."] = "Appuyez sur %s+C pour copier, puis collez dans votre rapport.";
L["Search filter active - exporting only the rows currently shown."] = "Filtre de recherche actif – seules les lignes actuellement affichées sont exportées.";
