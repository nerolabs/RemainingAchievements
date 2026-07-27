-- Export.lua: spreadsheet export (tab-separated) and copy-paste dialog.
-- TSV rather than CSV: pasting tab-separated text into Google Sheets/Excel
-- splits straight into columns, so no intermediate file is needed.
local ADDON_NAME, RA = ...;

local Export = {};
RA.Export = Export;

local dialog, editBox;

-- No "Completed" column: every exported row is by definition incomplete.
-- "Stashed" = stashed for later by the user in this addon; "Hidden" = hidden
-- by Blizzard until earned; "Faction" = set only on opposite-faction rows.
local COLUMNS = { "ID", "Name", "Category", "Points", "Description", "RewardText", "EarnedByMe", "Stashed", "Hidden", "Faction", "WowheadURL" };

local function CleanField(value)
	local text = tostring(value == nil and "" or value);
	return (text:gsub("[\t\r\n]+", " "));
end

local categoryPathCache = {};
local function GetCategoryPath(achievementID)
	local catID = GetAchievementCategory(achievementID);
	if not catID then
		return "";
	end
	local path = categoryPathCache[catID];
	if not path then
		local title, parentID = GetCategoryInfo(catID);
		path = title or "";
		if parentID and parentID > 0 then
			local parentTitle = GetCategoryInfo(parentID);
			if parentTitle and parentTitle ~= "" then
				path = parentTitle .. " > " .. path;
			end
		end
		categoryPathCache[catID] = path;
	end
	return path;
end

local function BuildTSV(entries)
	local lines = { table.concat(COLUMNS, "\t") };
	for _, entry in ipairs(entries) do
		local id, name, points, _, _, _, _, description, _, _, rewardText, _, wasEarnedByMe = GetAchievementInfo(entry.id);
		if id then
			lines[#lines + 1] = table.concat({
				id,
				CleanField(name),
				CleanField(GetCategoryPath(id)),
				points or 0,
				CleanField(description),
				CleanField(rewardText),
				tostring(wasEarnedByMe == true),
				tostring(RA.IsHidden(id)),
				tostring(entry.secret == true),
				(entry.mirror == RA.FACTION_HORDE and "Horde") or (entry.mirror == RA.FACTION_ALLIANCE and "Alliance") or "",
				"https://www.wowhead.com/achievement=" .. id,
			}, "\t");
		end
	end
	return table.concat(lines, "\n");
end

local function CreateDialog()
	dialog = CreateFrame("Frame", "RemainingAchievementsExportDialog", UIParent, "DefaultPanelFlatTemplate");
	dialog:SetSize(540, 420);
	dialog:SetPoint("CENTER");
	dialog:SetFrameStrata("DIALOG");
	dialog:SetToplevel(true);
	dialog:SetMovable(true);
	dialog:EnableMouse(true);
	dialog:RegisterForDrag("LeftButton");
	dialog:SetScript("OnDragStart", dialog.StartMoving);
	dialog:SetScript("OnDragStop", dialog.StopMovingOrSizing);
	dialog:SetClampedToScreen(true);
	dialog.TitleContainer.TitleText:SetText("Remaining Achievements - Spreadsheet Export");
	tinsert(UISpecialFrames, "RemainingAchievementsExportDialog");

	local close = CreateFrame("Button", nil, dialog, "UIPanelCloseButton");
	close:SetPoint("TOPRIGHT", -2, -1);
	close:SetScript("OnClick", function()
		dialog:Hide();
	end);

	local hint = dialog:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall");
	hint:SetPoint("TOPLEFT", 14, -30);
	hint:SetText("Press " .. (IsMacClient() and "Cmd" or "Ctrl") .. "+C to copy, then paste directly into Google Sheets or Excel.");

	dialog.FilterNote = dialog:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	dialog.FilterNote:SetPoint("TOPLEFT", hint, "BOTTOMLEFT", 0, -2);
	dialog.FilterNote:SetText("Search filter active - exporting only the rows currently shown.");

	local scrollFrame = CreateFrame("ScrollFrame", nil, dialog, "UIPanelScrollFrameTemplate");
	scrollFrame:SetPoint("TOPLEFT", 14, -64);
	scrollFrame:SetPoint("BOTTOMRIGHT", -32, 12);

	editBox = CreateFrame("EditBox", nil, scrollFrame);
	editBox:SetMultiLine(true);
	editBox:SetMaxLetters(0);
	editBox:SetFontObject(GameFontHighlightSmall);
	editBox:SetWidth(480);
	editBox:SetAutoFocus(false);
	editBox:SetScript("OnEscapePressed", function()
		dialog:Hide();
	end);
	scrollFrame:SetScrollChild(editBox);
	scrollFrame:SetScript("OnSizeChanged", function(self, width)
		editBox:SetWidth(width);
	end);
end

-- Generic read-only copy-paste dialog (same Cmd/Ctrl+C flow as the export box),
-- reused by /radiagnose. Separate frame from the export dialog so neither
-- affects the other.
local copyDialog, copyEditBox;
function RA.ShowCopyDialog(titleText, bodyText)
	if not copyDialog then
		copyDialog = CreateFrame("Frame", "RemainingAchievementsCopyDialog", UIParent, "DefaultPanelFlatTemplate");
		copyDialog:SetSize(540, 420);
		copyDialog:SetPoint("CENTER");
		copyDialog:SetFrameStrata("DIALOG");
		copyDialog:SetToplevel(true);
		copyDialog:SetMovable(true);
		copyDialog:EnableMouse(true);
		copyDialog:RegisterForDrag("LeftButton");
		copyDialog:SetScript("OnDragStart", copyDialog.StartMoving);
		copyDialog:SetScript("OnDragStop", copyDialog.StopMovingOrSizing);
		copyDialog:SetClampedToScreen(true);
		tinsert(UISpecialFrames, "RemainingAchievementsCopyDialog");

		local close = CreateFrame("Button", nil, copyDialog, "UIPanelCloseButton");
		close:SetPoint("TOPRIGHT", -2, -1);
		close:SetScript("OnClick", function()
			copyDialog:Hide();
		end);

		local hint = copyDialog:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall");
		hint:SetPoint("TOPLEFT", 14, -30);
		hint:SetText("Press " .. (IsMacClient() and "Cmd" or "Ctrl") .. "+C to copy, then paste into your report.");

		local scrollFrame = CreateFrame("ScrollFrame", nil, copyDialog, "UIPanelScrollFrameTemplate");
		scrollFrame:SetPoint("TOPLEFT", 14, -50);
		scrollFrame:SetPoint("BOTTOMRIGHT", -32, 12);

		copyEditBox = CreateFrame("EditBox", nil, scrollFrame);
		copyEditBox:SetMultiLine(true);
		copyEditBox:SetMaxLetters(0);
		copyEditBox:SetFontObject(GameFontHighlightSmall);
		copyEditBox:SetWidth(480);
		copyEditBox:SetAutoFocus(false);
		copyEditBox:SetScript("OnEscapePressed", function()
			copyDialog:Hide();
		end);
		scrollFrame:SetScrollChild(copyEditBox);
		scrollFrame:SetScript("OnSizeChanged", function(self, width)
			copyEditBox:SetWidth(width);
		end);
	end
	copyDialog.TitleContainer.TitleText:SetText(titleText);
	copyDialog:Show();
	copyEditBox:SetText(bodyText);
	copyEditBox:SetCursorPosition(0);
	copyEditBox:SetFocus();
	copyEditBox:HighlightText();
end

function Export.Show(entries, isFiltered)
	if not dialog then
		CreateDialog();
	end
	dialog.TitleContainer.TitleText:SetText(("Remaining Achievements - Export (%d rows)"):format(#entries));
	dialog.FilterNote:SetShown(isFiltered);
	dialog:Show();
	editBox:SetText(BuildTSV(entries));
	editBox:SetCursorPosition(0);
	editBox:SetFocus();
	editBox:HighlightText();
end
