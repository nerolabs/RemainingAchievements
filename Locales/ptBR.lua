-- ptBR (machine translation). Missing keys fall back to enUS via RA.L.
local ADDON_NAME, RA = ...;
if GetLocale() ~= "ptBR" then return end
local L = RA.L;

L["Remaining"] = "Restantes";
L["%s remaining"] = "%s restantes";
L["%s points unearned"] = "%s pontos não obtidos";
L["(hidden)"] = "(oculta)";

L["Include Feats of Strength |cffff7f00(beta)|r"] = "Incluir Feitos de Força |cffff7f00(beta)|r";
L["Include hidden achievements"] = "Incluir conquistas ocultas";
L["Include opposite faction"] = "Incluir facção oposta";
L["Show stashed for later (%d)"] = "Mostrar as guardadas para depois (%d)";

L["Feats of Strength"] = "Feitos de Força";
L["Obtainable Feats of Strength for your faction, including known hidden ones. Retired content is filtered out: promotions, old PvP titles, one-time world events, realm firsts, and past-season feats. Beta: the game has no obtainability data, so report anything that slips through."] = "Feitos de Força obteníveis para a sua facção, incluindo os ocultos conhecidos. Conteúdo descontinuado é filtrado: promoções, títulos de JxJ antigos, eventos mundiais únicos, primeiros do reino e feitos de temporadas passadas. Beta: o jogo não fornece dados de obtenibilidade, então relate qualquer coisa que passe despercebida.";
L["Hidden achievements"] = "Conquistas ocultas";
L["True hidden achievements: point-earning achievements Blizzard hides from the UI until they are earned. Feats of Strength are not included here - they have their own toggle below. May occasionally list one that is no longer obtainable - please report any you spot."] = "Verdadeiras conquistas ocultas: conquistas que dão pontos e que a Blizzard oculta da interface até serem obtidas. Os Feitos de Força não são incluídos aqui: têm sua própria opção abaixo. Ocasionalmente pode listar uma que não é mais obtenível; por favor, relate as que notar.";
L["Stashed for later"] = "Guardadas para depois";
L["Use a row's X button or right-click menu to stash achievements you want to set aside, removing them from the Remaining list and its counts. This toggle shows them again with one-click restore. Stashing persists account-wide."] = "Use o botão X de uma linha ou o menu do clique direito para guardar as conquistas que deseja deixar de lado; elas são removidas da lista de Restantes e de suas contagens. Esta opção as mostra novamente com restauração em um clique. O que é guardado permanece em toda a conta.";
L["Opposite-faction achievements"] = "Conquistas da facção oposta";
L["Achievements only the other faction can still earn, DataForAzeroth-style. Uses the Remaining list recorded when a character of that faction opens this tab."] = "Conquistas que apenas a outra facção ainda pode obter, no estilo DataForAzeroth. Usa a lista de Restantes registrada quando um personagem dessa facção abre esta aba.";
L["Opposite-faction totals"] = "Totais da facção oposta";
L["These factional points count towards totals on DataForAzeroth."] = "Estes pontos de facção contam para os totais no DataForAzeroth.";

L["Using the %s list from %s, recorded %s (%s)."] = "Usando a lista de %s de %s, registrada em %s (%s).";
L["Log into a %s character and open the Remaining tab to refresh it."] = "Entre com um personagem %s e abra a aba Restantes para atualizá-la.";
L["No %s data yet: log into a %s character and open the Remaining tab once."] = "Ainda sem dados de %s: entre com um personagem %s e abra a aba Restantes uma vez.";
L["Not available on neutral characters."] = "Não disponível em personagens neutros.";
L["today"] = "hoje";
L["yesterday"] = "ontem";
L["%d days ago"] = "%d dias atrás";

L["Stash for later"] = "Guardar para depois";
L["Return to the Remaining list"] = "Voltar à lista de Restantes";
L["Return to list"] = "Voltar à lista";
L["Track on HUD"] = "Rastrear no HUD";
L["Untrack on HUD"] = "Parar de rastrear no HUD";
L["Link to chat"] = "Vincular ao chat";

L["Export Spreadsheet"] = "Exportar planilha";
L["Updating..."] = "Atualizando...";

L["Remaining Achievements - Spreadsheet Export"] = "Conquistas restantes – Exportação de planilha";
L["Remaining Achievements - Export (%d rows)"] = "Conquistas restantes – Exportação (%d linhas)";
L["Press %s+C to copy, then paste directly into Google Sheets or Excel."] = "Pressione %s+C para copiar e cole diretamente no Google Sheets ou Excel.";
L["Press %s+C to copy, then paste into your report."] = "Pressione %s+C para copiar e cole no seu relatório.";
L["Search filter active - exporting only the rows currently shown."] = "Filtro de busca ativo – exportando apenas as linhas exibidas no momento.";
