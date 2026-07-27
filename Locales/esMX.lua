-- esMX (machine translation). Missing keys fall back to enUS via RA.L.
local ADDON_NAME, RA = ...;
if GetLocale() ~= "esMX" then return end
local L = RA.L;

L["Remaining"] = "Restantes";
L["%s remaining"] = "%s restantes";
L["%s points unearned"] = "%s puntos sin obtener";
L["(hidden)"] = "(oculto)";

L["Include Feats of Strength |cffff7f00(beta)|r"] = "Incluir proezas |cffff7f00(beta)|r";
L["Include hidden achievements"] = "Incluir logros ocultos";
L["Include opposite faction"] = "Incluir la facción contraria";
L["Show stashed for later (%d)"] = "Mostrar los guardados para después (%d)";

L["Feats of Strength"] = "Proezas";
L["Obtainable Feats of Strength for your faction, including known hidden ones. Retired content is filtered out: promotions, old PvP titles, one-time world events, realm firsts, and past-season feats. Beta: the game has no obtainability data, so report anything that slips through."] = "Proezas obtenibles para tu facción, incluidas las ocultas conocidas. Se filtra el contenido retirado: promociones, títulos JcJ antiguos, eventos mundiales únicos, primeros del reino y proezas de temporadas pasadas. Beta: el juego no ofrece datos de obtenibilidad, así que reporta cualquier cosa que se cuele.";
L["Hidden achievements"] = "Logros ocultos";
L["True hidden achievements: point-earning achievements Blizzard hides from the UI until they are earned. Feats of Strength are not included here - they have their own toggle below. May occasionally list one that is no longer obtainable - please report any you spot."] = "Verdaderos logros ocultos: logros que otorgan puntos y que Blizzard oculta de la interfaz hasta que se consiguen. Las proezas no se incluyen aquí: tienen su propia opción más abajo. En ocasiones puede aparecer alguno que ya no es obtenible; reporta los que detectes.";
L["Stashed for later"] = "Guardados para después";
L["Use a row's X button or right-click menu to stash achievements you want to set aside, removing them from the Remaining list and its counts. This toggle shows them again with one-click restore. Stashing persists account-wide."] = "Usa el botón X de una fila o el menú del clic derecho para guardar los logros que quieras apartar; se eliminan de la lista de Restantes y de sus conteos. Esta opción vuelve a mostrarlos con restauración de un clic. Lo guardado se conserva en toda la cuenta.";
L["Opposite-faction achievements"] = "Logros de la facción contraria";
L["Achievements only the other faction can still earn, DataForAzeroth-style. Uses the Remaining list recorded when a character of that faction opens this tab."] = "Logros que solo la otra facción aún puede conseguir, al estilo de DataForAzeroth. Usa la lista de Restantes registrada cuando un personaje de esa facción abre esta pestaña.";
L["Opposite-faction totals"] = "Totales de la facción contraria";
L["These factional points count towards totals on DataForAzeroth."] = "Estos puntos de facción cuentan para los totales en DataForAzeroth.";

L["Using the %s list from %s, recorded %s (%s)."] = "Usando la lista de %s de %s, registrada el %s (%s).";
L["Log into a %s character and open the Remaining tab to refresh it."] = "Inicia sesión con un personaje %s y abre la pestaña Restantes para actualizarla.";
L["No %s data yet: log into a %s character and open the Remaining tab once."] = "Aún no hay datos de %s: inicia sesión con un personaje %s y abre la pestaña Restantes una vez.";
L["Not available on neutral characters."] = "No disponible en personajes neutrales.";
L["today"] = "hoy";
L["yesterday"] = "ayer";
L["%d days ago"] = "hace %d días";

L["Stash for later"] = "Guardar para después";
L["Return to the Remaining list"] = "Volver a la lista de Restantes";
L["Return to list"] = "Volver a la lista";
L["Track on HUD"] = "Seguir en el HUD";
L["Untrack on HUD"] = "Dejar de seguir en el HUD";
L["Link to chat"] = "Enlazar al chat";

L["Export Spreadsheet"] = "Exportar hoja de cálculo";
L["Updating..."] = "Actualizando...";

L["Remaining Achievements - Spreadsheet Export"] = "Logros restantes: exportación de hoja de cálculo";
L["Remaining Achievements - Export (%d rows)"] = "Logros restantes: exportación (%d filas)";
L["Press %s+C to copy, then paste directly into Google Sheets or Excel."] = "Presiona %s+C para copiar y luego pega directamente en Google Sheets o Excel.";
L["Press %s+C to copy, then paste into your report."] = "Presiona %s+C para copiar y luego pega en tu reporte.";
L["Search filter active - exporting only the rows currently shown."] = "Filtro de búsqueda activo: solo se exportan las filas mostradas actualmente.";
