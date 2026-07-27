-- UI.lua: "Remaining" tab, panel, scroll box and controls.
local ADDON_NAME, RA = ...;

local UI = {};
RA.UI = UI;

local panel, controls, list, scrollBox, scrollBar, selectionBehavior;
local searchText; -- lowercased current filter, nil when empty

function UI.IsShown()
	return panel ~= nil and panel:IsShown();
end

-- Entries currently displayable, plus counts for the header
-- (remaining/points always exclude hidden, regardless of the toggle;
-- opposite-faction entries are listed but never counted, matching the
-- in-game point total). Empty until the first scan completes.
function UI.GetDisplayEntries()
	local showHidden = RA.db.settings.showHidden;
	local entries, remaining, points, hiddenCount, mirrorCount, mirrorPoints = {}, 0, 0, 0, 0, 0;
	for _, entry in ipairs(RA.GetRemaining() or {}) do
		local isHidden = RA.IsHidden(entry.id);
		if isHidden then
			hiddenCount = hiddenCount + 1;
		elseif entry.mirror ~= nil then
			mirrorCount = mirrorCount + 1;
			mirrorPoints = mirrorPoints + entry.points;
		else
			remaining = remaining + 1;
			points = points + entry.points;
		end
		if (showHidden or not isHidden) and (not searchText or entry.searchText:find(searchText, 1, true)) then
			entries[#entries + 1] = entry;
		end
	end
	return entries, remaining, points, hiddenCount, mirrorCount, mirrorPoints;
end

local function UpdateCountsDisplay(remaining, points, hiddenCount, mirrorCount, mirrorPoints)
	mirrorCount, mirrorPoints = mirrorCount or 0, mirrorPoints or 0;
	local countSuffix, pointsSuffix = "", "";
	if RA.db.settings.includeMirror then
		local _, otherFaction = RA.GetOppositeSnapshot();
		if otherFaction then
			-- Inline, e.g. "45 remaining (+10 Horde)": the extra work only the
			-- other faction can do, which DataForAzeroth counts toward totals.
			local color = (otherFaction == "Horde") and "|cffff4444" or "|cff44aaff";
			countSuffix = (" %s(+%s %s)|r"):format(color, BreakUpLargeNumbers(mirrorCount), otherFaction);
			pointsSuffix = (" %s(+%s %s)|r"):format(color, BreakUpLargeNumbers(mirrorPoints), otherFaction);
		end
	end
	controls.CountText:SetText(BreakUpLargeNumbers(remaining) .. " remaining" .. countSuffix);
	controls.PointsText:SetText(BreakUpLargeNumbers(points) .. " points unearned" .. pointsSuffix);
	controls.ShowHiddenLabel:SetText(("Show stashed for later (%d)"):format(hiddenCount));
end

function UI.UpdateCounts()
	UpdateCountsDisplay(select(2, UI.GetDisplayEntries()));
end

local function OnScanComplete()
	if panel then
		UI.Refresh();
	end
end

-- resetScroll jumps back to the top (used when the search text changes);
-- otherwise the user's scroll position and expanded row survive the rebuild.
function UI.Refresh(resetScroll)
	if not panel then
		return;
	end
	if not RA.GetRemaining() then
		-- Scan pending: show the busy overlay (dimmed spinner) over whatever
		-- rows remain so a toggle that triggers a rescan gives obvious feedback.
		-- Re-runs once the async scan lands.
		panel.BusyOverlay:Show();
		RA.RequestRemaining(OnScanComplete);
		return;
	end
	panel.BusyOverlay:Hide();
	local entries, remaining, points, hiddenCount, mirrorCount, mirrorPoints = UI.GetDisplayEntries();
	local selected = selectionBehavior:GetFirstSelectedElementData();
	local selectedID = selected and selected.id;
	local elements = {};
	for i, entry in ipairs(entries) do
		-- category/index feed CalculateSelectedHeight, which lacks Init's
		-- by-id fallback; including them routes both through the same
		-- GetAchievementInfo(cat, i) lookup Blizzard's own list uses.
		-- Progressive chain steps have no index and are sized by id instead
		-- (see the extent calculator).
		elements[i] = { id = entry.id, category = entry.category, index = entry.index, secret = entry.secret, mirror = entry.mirror };
	end
	scrollBox:SetDataProvider(CreateDataProvider(elements), not resetScroll and ScrollBoxConstants.RetainScrollPosition or nil);
	if selectedID then
		local elementData = scrollBox:GetDataProvider():FindElementDataByPredicate(function(data)
			return data.id == selectedID;
		end);
		if elementData then
			selectionBehavior:SelectElementData(elementData);
		end
	end
	UpdateCountsDisplay(remaining, points, hiddenCount, mirrorCount, mirrorPoints);
end

-- Mirrors AchievementTemplateMixin.CalculateSelectedHeight, which resolves
-- elementData only through GetAchievementInfo(category, index) and so cannot
-- size progressive chain steps that have no list coordinates; this does the
-- same math from a by-id lookup. Blizzard's guild-view minimum is dropped
-- (our list never shows guild achievements). Inlined file-locals from
-- Blizzard_AchievementUI.lua: 3 collapsed description lines, forced-column
-- thresholds of 20 criteria / 220px.
local function CalculateSelectedHeightByID(achievementID)
	local totalHeight = ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT;
	local objectivesHeight = 0;

	if not AchievementFrame.textCheckWidth then
		AchievementFrame.PlaceholderName:SetText("- ");
		AchievementFrame.textCheckWidth = AchievementFrame.PlaceholderName:GetStringWidth();
	end

	local id, _, _, completed, _, _, _, description, _, _, rewardText = GetAchievementInfo(achievementID);
	if completed and GetPreviousAchievement(id) then
		local achievementCount = 1;
		local nextID = id;
		while GetPreviousAchievement(nextID) do
			achievementCount = achievementCount + 1;
			nextID = GetPreviousAchievement(nextID);
		end
		local maxAchievementsPerRow = 6;
		objectivesHeight = math.ceil(achievementCount / maxAchievementsPerRow) * ACHIEVEMENTUI_PROGRESSIVEHEIGHT;
	else
		local numExtraCriteriaRows = 0;
		local maxCriteriaWidth = 0;
		local textStrings = 0;
		local progressBars = 0;
		local metas = 0;
		local numMetaRows = 0;
		local numCriteriaRows = 0;
		if not completed and GetAchievementGuildRep(id) then
			numExtraCriteriaRows = numExtraCriteriaRows + 1;
		end

		for i = 1, GetAchievementNumCriteria(id) do
			local criteriaString, criteriaType, criteriaCompleted, _, _, _, criteriaFlags, assetID = GetAchievementCriteriaInfo(id, i);
			if criteriaType == CRITERIA_TYPE_ACHIEVEMENT and assetID then
				metas = metas + 1;
				if metas == 1 or (math.fmod(metas, 2) ~= 0) then
					numMetaRows = numMetaRows + 1;
				end
			elseif bit.band(criteriaFlags, EVALUATION_TREE_FLAG_PROGRESS_BAR) == EVALUATION_TREE_FLAG_PROGRESS_BAR then
				progressBars = progressBars + 1;
				numCriteriaRows = numCriteriaRows + 1;
			else
				textStrings = textStrings + 1;
				local stringWidth;
				local maxCriteriaContentWidth;
				if criteriaCompleted then
					maxCriteriaContentWidth = ACHIEVEMENTUI_MAXCONTENTWIDTH - ACHIEVEMENTUI_CRITERIACHECKWIDTH;
					AchievementFrame.PlaceholderName:SetText(criteriaString);
					stringWidth = math.min(AchievementFrame.PlaceholderName:GetStringWidth(), maxCriteriaContentWidth);
				else
					maxCriteriaContentWidth = ACHIEVEMENTUI_MAXCONTENTWIDTH - AchievementFrame.textCheckWidth;
					AchievementFrame.PlaceholderName:SetText("- " .. criteriaString);
					stringWidth = math.min(AchievementFrame.PlaceholderName:GetStringWidth() - AchievementFrame.textCheckWidth, maxCriteriaContentWidth);
				end
				if AchievementFrame.PlaceholderName:GetWidth() > maxCriteriaContentWidth then
					AchievementFrame.PlaceholderName:SetWidth(maxCriteriaContentWidth);
				end
				maxCriteriaWidth = math.max(maxCriteriaWidth, stringWidth + ACHIEVEMENTUI_CRITERIACHECKWIDTH);
				numCriteriaRows = numCriteriaRows + 1;
			end
		end

		if textStrings > 0 and progressBars > 0 then
			-- Mixed criteria render single-column; keep numCriteriaRows as-is.
		elseif textStrings > 1 then
			local numColumns = math.floor(ACHIEVEMENTUI_MAXCONTENTWIDTH / maxCriteriaWidth);
			if numColumns == 1 and textStrings >= 20 and maxCriteriaWidth <= 220 then
				numColumns = 2;
			end
			if numColumns > 1 then
				numCriteriaRows = math.ceil(numCriteriaRows / numColumns);
			end
		end

		numCriteriaRows = numCriteriaRows + numExtraCriteriaRows;
		objectivesHeight = numMetaRows * ACHIEVEMENTBUTTON_METAROWHEIGHT + numCriteriaRows * ACHIEVEMENTBUTTON_CRITERIAROWHEIGHT;
		if metas > 0 or progressBars > 0 then
			objectivesHeight = objectivesHeight + 10;
		end
	end

	totalHeight = totalHeight + objectivesHeight;

	AchievementFrame.PlaceholderHiddenDescription:SetText(description);
	local descriptionHeight = AchievementFrame.PlaceholderHiddenDescription:GetHeight();
	-- Same AchievementDescriptionFont Blizzard measures its line count with.
	local _, fontHeight = AchievementFrame.PlaceholderHiddenDescription:GetFont();
	local numLines = math.ceil(descriptionHeight / fontHeight);
	if totalHeight ~= ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT or numLines > 3 then
		totalHeight = totalHeight + descriptionHeight - ACHIEVEMENTBUTTON_DESCRIPTIONHEIGHT;
		if rewardText ~= "" then
			totalHeight = totalHeight + 4;
		end
	end

	return totalHeight;
end

-- [[ Row behavior ]] --

local function UpdateRowHiddenState(button)
	local isHidden = RA.IsHidden(button.id);
	button:SetAlpha(isHidden and 0.45 or 1);
	local hideButton = button.RAHideButton;
	if isHidden then
		hideButton:SetNormalTexture("Interface\\Buttons\\UI-RefreshButton");
		hideButton.tooltipText = "Return to the Remaining list";
	else
		hideButton:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up");
		hideButton.tooltipText = "Stash for later";
	end
end

local function OnHideButtonClick(hideButton)
	local row = hideButton:GetParent();
	local elementData = row:GetElementData();
	if not elementData then
		return;
	end
	RA.SetHidden(elementData.id, not RA.IsHidden(elementData.id));
	if RA.db.settings.showHidden then
		UpdateRowHiddenState(row);
	else
		local dataProvider = scrollBox:GetDataProvider();
		if dataProvider then
			dataProvider:Remove(elementData);
		end
	end
	UI.UpdateCounts();
end

local function HideButtonOnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(self.tooltipText, 1, 1, 1);
	GameTooltip:Show();
end

-- Standalone HUD-tracking toggle (mirrors AchievementTemplateMixin:ToggleTracking
-- without needing a live row, since pooled rows can be recycled under a menu).
local function ToggleHUDTracking(id)
	local trackingType = Enum.ContentTrackingType.Achievement;
	if C_ContentTracking.IsTracking(trackingType, id) then
		C_ContentTracking.StopTracking(trackingType, id, Enum.ContentTrackingStopType.Manual);
		return;
	end
	if #C_ContentTracking.GetTrackedIDs(trackingType) >= Constants.ContentTrackingConsts.MaxTrackedAchievements then
		UIErrorsFrame:AddMessage(format(ACHIEVEMENT_WATCH_TOO_MANY, Constants.ContentTrackingConsts.MaxTrackedAchievements), 1.0, 0.1, 0.1, 1.0);
		return;
	end
	local trackingError = C_ContentTracking.StartTracking(trackingType, id);
	if trackingError then
		ContentTrackingUtil.DisplayTrackingError(trackingError);
	end
end

local function ShowRowMenu(row)
	local elementData = row:GetElementData();
	if not elementData then
		return;
	end
	local id = elementData.id;
	MenuUtil.CreateContextMenu(row, function(owner, rootDescription)
		rootDescription:SetTag("MENU_REMAINING_ACHIEVEMENTS_ROW");
		if RA.IsHidden(id) then
			rootDescription:CreateButton("Return to list", function()
				RA.SetHidden(id, false);
				UI.Refresh();
			end);
		else
			rootDescription:CreateButton("Stash for later", function()
				RA.SetHidden(id, true);
				UI.Refresh();
			end);
		end
		local isTracked = C_ContentTracking.IsTracking(Enum.ContentTrackingType.Achievement, id);
		rootDescription:CreateButton(isTracked and "Untrack on HUD" or "Track on HUD", function()
			ToggleHUDTracking(id);
		end);
		rootDescription:CreateButton("Link to chat", function()
			local link = GetAchievementLink(id);
			if link then
				ChatFrameUtil.InsertLink(link);
			end
		end);
	end);
end

-- Replaces AchievementTemplateMixin:OnClick, whose ProcessClick selects against
-- Blizzard's file-local selection behavior instead of ours.
local function OnRowClick(row, mouseButton)
	if mouseButton == "RightButton" then
		ShowRowMenu(row);
		return;
	end
	local elementData = row:GetElementData();
	if not elementData then
		return;
	end
	local handled = false;
	if IsModifiedClick("CHATLINK") then
		local link = GetAchievementLink(elementData.id);
		if link then
			handled = ChatFrameUtil.InsertLink(link);
		end
	end
	if not handled and IsModifiedClick("QUESTWATCHTOGGLE") then
		row:ToggleTracking();
		handled = true;
	end
	if not handled then
		selectionBehavior:ToggleSelect(row);
	end
end

local function InitializeRow(button, elementData)
	button:Init(elementData);
	-- Init just set the Label from the achievement name, so pooled reuse
	-- can't stack the tags.
	if elementData.mirror ~= nil then
		local tag = (elementData.mirror == RA.FACTION_HORDE)
			and "|cffff4444(Horde)|r" or "|cff44aaff(Alliance)|r";
		button.Label:SetText(button.Label:GetText() .. " " .. tag);
	elseif elementData.secret then
		button.Label:SetText(button.Label:GetText() .. " |cff71d5ff(hidden)|r");
	end
	if not button.RAHideButton then
		button:RegisterForClicks("LeftButtonUp", "RightButtonUp");
		button:SetScript("OnClick", OnRowClick);
		local hideButton = CreateFrame("Button", nil, button);
		hideButton:SetSize(18, 18);
		-- Left of the points shield, which occupies the top-right corner.
		hideButton:SetPoint("TOPRIGHT", -72, -6);
		hideButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD");
		hideButton:SetScript("OnClick", OnHideButtonClick);
		hideButton:SetScript("OnEnter", HideButtonOnEnter);
		hideButton:SetScript("OnLeave", GameTooltip_Hide);
		button.RAHideButton = hideButton;
	end
	UpdateRowHiddenState(button);
end

-- [[ Panel construction ]] --

local function CreatePanel()
	panel = CreateFrame("Frame", "RemainingAchievementsPanel", AchievementFrame);
	panel:SetAllPoints();
	panel:Hide();

	-- Left pane: controls, mirroring AchievementFrame.Categories geometry.
	controls = CreateFrame("Frame", nil, panel, "AchivementGoldBorderBackdrop");
	controls:SetPoint("TOPLEFT", AchievementFrame, "TOPLEFT", 21, -19);
	controls:SetPoint("BOTTOMLEFT", AchievementFrame, "BOTTOMLEFT", 21, 20);
	controls:SetWidth(175);

	local searchBox = CreateFrame("EditBox", nil, controls, "SearchBoxTemplate");
	searchBox:SetSize(150, 20);
	searchBox:SetPoint("TOP", 3, -16);
	searchBox:SetAutoFocus(false);
	local searchTimer;
	searchBox:HookScript("OnTextChanged", function(box)
		local text = (box:GetText() or ""):lower():gsub("^%s+", ""):gsub("%s+$", "");
		text = (text ~= "") and text or nil;
		if text == searchText then
			return;
		end
		searchText = text;
		if searchTimer then
			searchTimer:Cancel();
		end
		searchTimer = C_Timer.NewTimer(0.25, function()
			if UI.IsShown() then
				UI.Refresh(true);
			end
		end);
	end);

	controls.CountText = controls:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	controls.CountText:SetPoint("TOPLEFT", 12, -52);
	controls.PointsText = controls:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall");
	controls.PointsText:SetPoint("TOPLEFT", controls.CountText, "BOTTOMLEFT", 0, -4);

	-- Hover note for the "(+N Faction)" suffixes the mirror toggle adds.
	local countsHover = CreateFrame("Frame", nil, controls);
	countsHover:SetPoint("TOPLEFT", controls.CountText, "TOPLEFT", 0, 2);
	countsHover:SetPoint("BOTTOMRIGHT", controls.PointsText, "BOTTOMRIGHT", 0, -2);
	countsHover:EnableMouse(true);
	countsHover:SetScript("OnEnter", function(self)
		if not RA.db.settings.includeMirror then
			return;
		end
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText("Opposite-faction totals", 1, 1, 1);
		GameTooltip:AddLine("These factional points count towards totals on DataForAzeroth.", nil, nil, nil, true);
		GameTooltip:Show();
	end);
	countsHover:SetScript("OnLeave", GameTooltip_Hide);

	-- Toggle order (top to bottom): opposite faction, stashed, hidden
	-- achievements, FoS. fosCheck is re-anchored below secretCheck after the
	-- others exist.
	local fosCheck = CreateFrame("CheckButton", nil, controls, "UICheckButtonTemplate");
	fosCheck:SetSize(26, 26);
	fosCheck:SetChecked(RA.db.settings.includeFoS);
	fosCheck:SetScript("OnClick", function(self)
		RA.db.settings.includeFoS = self:GetChecked() and true or false;
		RA.InvalidateCache();
		UI.Refresh();
	end);
	fosCheck:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText("Feats of Strength", 1, 1, 1);
		GameTooltip:AddLine("Obtainable Feats of Strength for your faction, including known hidden ones. Retired content is filtered out: promotions, old PvP titles, one-time world events, realm firsts, and past-season feats. Beta: the game has no obtainability data, so report anything that slips through.", nil, nil, nil, true);
		GameTooltip:Show();
	end);
	fosCheck:SetScript("OnLeave", GameTooltip_Hide);
	local fosLabel = controls:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall");
	fosLabel:SetPoint("LEFT", fosCheck, "RIGHT", 2, 0);
	fosLabel:SetPoint("RIGHT", controls, "RIGHT", -8, 0);
	fosLabel:SetJustifyH("LEFT");
	fosLabel:SetText("Include Feats of Strength |cffff7f00(beta)|r");

	local hiddenCheck = CreateFrame("CheckButton", nil, controls, "UICheckButtonTemplate");
	hiddenCheck:SetSize(26, 26);
	hiddenCheck:SetPoint("TOPLEFT", 8, -126); -- second slot, below mirrorCheck
	hiddenCheck:SetChecked(RA.db.settings.showHidden);
	hiddenCheck:SetScript("OnClick", function(self)
		RA.db.settings.showHidden = self:GetChecked() and true or false;
		UI.Refresh();
	end);
	hiddenCheck:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText("Stashed for later", 1, 1, 1);
		GameTooltip:AddLine("Use a row's X button or right-click menu to stash achievements you want to set aside, removing them from the Remaining list and its counts. This toggle shows them again with one-click restore. Stashing persists account-wide.", nil, nil, nil, true);
		GameTooltip:Show();
	end);
	hiddenCheck:SetScript("OnLeave", GameTooltip_Hide);
	controls.ShowHiddenLabel = controls:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall");
	controls.ShowHiddenLabel:SetPoint("LEFT", hiddenCheck, "RIGHT", 2, 0);
	controls.ShowHiddenLabel:SetPoint("RIGHT", controls, "RIGHT", -8, 0);
	controls.ShowHiddenLabel:SetJustifyH("LEFT");
	controls.ShowHiddenLabel:SetText("Show stashed for later (0)");

	local secretCheck = CreateFrame("CheckButton", nil, controls, "UICheckButtonTemplate");
	secretCheck:SetSize(26, 26);
	secretCheck:SetPoint("TOPLEFT", hiddenCheck, "BOTTOMLEFT", 0, -4);
	secretCheck:SetChecked(RA.db.settings.includeSecret);
	secretCheck:SetScript("OnClick", function(self)
		RA.db.settings.includeSecret = self:GetChecked() and true or false;
		RA.InvalidateCache();
		UI.Refresh();
	end);
	secretCheck:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText("Hidden achievements", 1, 1, 1);
		GameTooltip:AddLine("True hidden achievements: point-earning achievements Blizzard hides from the UI until they are earned. Feats of Strength are not included here - they have their own toggle below. May occasionally list one that is no longer obtainable - please report any you spot.", nil, nil, nil, true);
		GameTooltip:Show();
	end);
	secretCheck:SetScript("OnLeave", GameTooltip_Hide);
	local secretLabel = controls:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall");
	secretLabel:SetPoint("LEFT", secretCheck, "RIGHT", 2, 0);
	secretLabel:SetPoint("RIGHT", controls, "RIGHT", -8, 0);
	secretLabel:SetJustifyH("LEFT");
	secretLabel:SetText("Include hidden achievements");

	local mirrorCheck = CreateFrame("CheckButton", nil, controls, "UICheckButtonTemplate");
	mirrorCheck:SetSize(26, 26);
	mirrorCheck:SetPoint("TOPLEFT", 8, -96); -- top slot
	mirrorCheck:SetChecked(RA.db.settings.includeMirror);
	mirrorCheck:SetScript("OnClick", function(self)
		RA.db.settings.includeMirror = self:GetChecked() and true or false;
		RA.InvalidateCache();
		UI.Refresh();
	end);
	mirrorCheck:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText("Opposite-faction achievements", 1, 1, 1);
		GameTooltip:AddLine("Achievements only the other faction can still earn, DataForAzeroth-style. Uses the Remaining list recorded when a character of that faction opens this tab.", nil, nil, nil, true);
		local snapshot, otherFaction = RA.GetOppositeSnapshot();
		if snapshot then
			-- Snapshots self-heal (account-completed entries are filtered out on
			-- every scan), so staleness is a soft nudge: green when fresh, amber
			-- past two weeks, orange past a month -- prompting a re-open on that
			-- faction so newly-added achievements make it into the list.
			local ageDays = math.floor((time() - (snapshot.when or 0)) / 86400);
			local ageText = (ageDays <= 0 and "today")
				or (ageDays == 1 and "yesterday")
				or (ageDays .. " days ago");
			local r, g, b = 0.6, 0.9, 0.6;
			if ageDays >= 30 then r, g, b = 1, 0.5, 0.3;
			elseif ageDays >= 14 then r, g, b = 1, 0.82, 0.3; end
			GameTooltip:AddLine(("Using the %s list from %s, recorded %s (%s)."):format(otherFaction, snapshot.character, date("%Y-%m-%d %H:%M", snapshot.when), ageText), r, g, b, true);
			if ageDays >= 14 then
				GameTooltip:AddLine(("Log into a %s character and open the Remaining tab to refresh it."):format(otherFaction), r, g, b, true);
			end
		elseif otherFaction then
			GameTooltip:AddLine(("No %s data yet: log into a %s character and open the Remaining tab once."):format(otherFaction, otherFaction), 1, 0.5, 0.3, true);
		else
			GameTooltip:AddLine("Not available on neutral characters.", 1, 0.5, 0.3, true);
		end
		GameTooltip:Show();
	end);
	mirrorCheck:SetScript("OnLeave", GameTooltip_Hide);
	local mirrorLabel = controls:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall");
	mirrorLabel:SetPoint("LEFT", mirrorCheck, "RIGHT", 2, 0);
	mirrorLabel:SetPoint("RIGHT", controls, "RIGHT", -8, 0);
	mirrorLabel:SetJustifyH("LEFT");
	mirrorLabel:SetText("Include opposite faction");
	fosCheck:SetPoint("TOPLEFT", secretCheck, "BOTTOMLEFT", 0, -4); -- bottom slot

	local exportButton = CreateFrame("Button", nil, controls, "UIPanelButtonTemplate");
	exportButton:SetSize(158, 22);
	exportButton:SetPoint("BOTTOM", 0, 14);
	exportButton:SetText("Export Spreadsheet");
	exportButton:SetScript("OnClick", function()
		if not RA.GetRemaining() then
			return; -- initial scan still running
		end
		local entries = UI.GetDisplayEntries();
		RA.Export.Show(entries, searchText ~= nil);
	end);

	-- Category filter: a dropdown of one checkbox per top-level category
	-- (all checked by default), so PvP, Pet Battles, etc. can be toggled off
	-- independently. Feats of Strength are excluded here (own toggle above).
	local categoriesDropdown = CreateFrame("DropdownButton", nil, controls, "WowStyle1DropdownTemplate");
	categoriesDropdown:SetSize(158, 22);
	categoriesDropdown:SetPoint("BOTTOM", exportButton, "TOP", 0, 8);
	local function UpdateCategoriesText()
		local hidden = 0;
		for _ in pairs(RA.db.settings.excludedCategories) do
			hidden = hidden + 1;
		end
		categoriesDropdown:SetDefaultText(hidden > 0
			and ("Categories (%d hidden)"):format(hidden) or "All categories");
	end
	local function SetCategoryExcluded(catID, excluded)
		RA.db.settings.excludedCategories[catID] = excluded or nil;
		RA.InvalidateCache();
		UpdateCategoriesText();
		UI.Refresh();
	end
	categoriesDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:CreateTitle("Show categories");
		rootDescription:CreateButton("Check all", function()
			wipe(RA.db.settings.excludedCategories);
			RA.InvalidateCache();
			UpdateCategoriesText();
			UI.Refresh();
			return MenuResponse.Refresh;
		end);
		rootDescription:CreateButton("Uncheck all", function()
			for _, cat in ipairs(RA.GetTopLevelCategories()) do
				RA.db.settings.excludedCategories[cat.id] = true;
			end
			RA.InvalidateCache();
			UpdateCategoriesText();
			UI.Refresh();
			return MenuResponse.Refresh;
		end);
		rootDescription:CreateDivider();
		for _, cat in ipairs(RA.GetTopLevelCategories()) do
			rootDescription:CreateCheckbox(cat.name, function()
				return not RA.db.settings.excludedCategories[cat.id];
			end, function()
				SetCategoryExcluded(cat.id, not RA.db.settings.excludedCategories[cat.id]);
				return MenuResponse.Refresh;
			end);
		end
	end);
	UpdateCategoriesText();

	-- Right pane: the list, mirroring AchievementFrame.Achievements geometry.
	list = CreateFrame("Frame", nil, panel);
	list:SetSize(504, 440);
	list:SetPoint("TOPLEFT", controls, "TOPRIGHT", 22, 0);
	list:SetPoint("BOTTOM", controls, "BOTTOM");

	local background = list:CreateTexture(nil, "BACKGROUND");
	background:SetTexture("Interface\\AchievementFrame\\UI-Achievement-AchievementBackground");
	background:SetPoint("TOPLEFT", 3, -3);
	background:SetPoint("BOTTOMRIGHT", -3, 3);
	background:SetTexCoord(0, 1, 0, 0.5);
	local darken = list:CreateTexture(nil, "ARTWORK");
	darken:SetColorTexture(0, 0, 0, 0.75);
	darken:SetPoint("TOPLEFT", background);
	darken:SetPoint("BOTTOMRIGHT", background);

	scrollBox = CreateFrame("Frame", nil, list, "WowScrollBoxList");
	scrollBox:SetFrameStrata("HIGH");
	scrollBox:SetPoint("TOPLEFT", 4, -3);
	scrollBox:SetPoint("BOTTOMRIGHT", 0, 5);

	scrollBar = CreateFrame("EventFrame", nil, list, "MinimalScrollBar");
	scrollBar:SetFrameStrata("HIGH");
	scrollBar:SetPoint("TOPLEFT", list, "TOPRIGHT", 6, -8);
	scrollBar:SetPoint("BOTTOMLEFT", list, "BOTTOMRIGHT", 6, 6);

	local border = CreateFrame("Frame", nil, list, "AchivementGoldBorderBackdrop");
	border:SetAllPoints();

	-- Busy overlay: a dimmed scrim + rotating spinner + label shown over the
	-- list whenever an async rescan runs (toggle change -- opposite faction is
	-- the slowest -- or an achievement earned). Stays obvious even when stale
	-- rows are still on screen, which the old top-corner text was not. DIALOG
	-- strata to cover the HIGH-strata scroll rows; swallows mouse so a row that
	-- is about to change can't be clicked mid-update.
	local busy = CreateFrame("Frame", nil, list);
	busy:SetFrameStrata("DIALOG");
	busy:SetPoint("TOPLEFT", background);
	busy:SetPoint("BOTTOMRIGHT", background);
	busy:EnableMouse(true);
	local scrim = busy:CreateTexture(nil, "BACKGROUND");
	scrim:SetAllPoints();
	scrim:SetColorTexture(0, 0, 0, 0.5);
	busy.spinner = busy:CreateTexture(nil, "ARTWORK");
	busy.spinner:SetTexture("Interface\\COMMON\\StreamCircle");
	busy.spinner:SetSize(44, 44);
	busy.spinner:SetPoint("CENTER", busy, "CENTER", 0, 12);
	local rot = busy.spinner:CreateAnimationGroup();
	rot:SetLooping("REPEAT");
	local spin = rot:CreateAnimation("Rotation");
	spin:SetDegrees(-360);
	spin:SetDuration(1);
	busy.label = busy:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
	busy.label:SetPoint("TOP", busy.spinner, "BOTTOM", 0, -10);
	busy.label:SetText("Updating...");
	busy:SetScript("OnShow", function() rot:Play(); end);
	busy:SetScript("OnHide", function() rot:Stop(); end);
	busy:Hide();
	panel.BusyOverlay = busy;

	local view = CreateScrollBoxListLinearView();
	view:SetElementExtentCalculator(function(dataIndex, elementData)
		if SelectionBehaviorMixin.IsElementDataIntrusiveSelected(elementData) then
			if elementData.index then
				return AchievementTemplateMixin.CalculateSelectedHeight(elementData);
			end
			return CalculateSelectedHeightByID(elementData.id);
		else
			return ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT;
		end
	end);
	view:SetElementInitializer("AchievementTemplate", InitializeRow);
	view:SetElementResetter(function(button)
		if SelectionBehaviorMixin.IsIntrusiveSelected(button) then
			button:GetObjectiveFrame():Clear();
		end
		button:SetAlpha(1);
	end);
	view:SetPadding(2, 0, 0, 4, 0);
	ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, view);

	selectionBehavior = ScrollUtil.AddSelectionBehavior(scrollBox, SelectionBehaviorFlags.Deselectable, SelectionBehaviorFlags.Intrusive);
	selectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, function(o, elementData, selected)
		local button = scrollBox:FindFrame(elementData);
		if button then
			button:SetSelected(selected);
		end
	end, panel);

	ScrollUtil.AddResizableChildrenBehavior(scrollBox);

	panel:SetScript("OnShow", function(self)
		self:RegisterEvent("CRITERIA_UPDATE");
		UI.Refresh();
	end);
	panel:SetScript("OnHide", function(self)
		self:UnregisterEvent("CRITERIA_UPDATE");
	end);
	panel:SetScript("OnEvent", function(self, event)
		if event == "CRITERIA_UPDATE" then
			-- Only re-init the selected (expanded) row; never rescan here.
			local selected = selectionBehavior:GetFirstSelectedElementData();
			if selected then
				local button = scrollBox:FindFrame(selected);
				if button then
					button:Init(selected);
				end
			end
		end
	end);
end

-- [[ Tab and Blizzard integration ]] --

function UI.Activate()
	AchievementFrame_UpdateTabs(UI.tabIndex);
	AchievementFrame_ShowSubFrame(); -- no args: hides every Blizzard subframe
	AchievementFrameCategories:Hide();
	AchievementFrame_HideFilterDropdown(AchievementFrame);
	AchievementFrameWaterMark:SetTexture("Interface\\AchievementFrame\\UI-Achievement-AchievementWatermark");
	AchievementFrameGuildEmblemLeft:Hide();
	AchievementFrameGuildEmblemRight:Hide();
	panel:Show();
end

local function Deactivate()
	if panel:IsShown() then
		panel:Hide();
		AchievementFrameCategories:Show();
	end
end

-- ElvUI's achievement skin only restyles AchievementFrameTab1-3; run our tab
-- through its public Skins API so it matches. HandleTab works standalone, so
-- it does not matter whether ElvUI's own skin has run yet.
local function ApplyElvUISkin(tab)
	if not C_AddOns.IsAddOnLoaded("ElvUI") then
		return;
	end
	local E = unpack(_G.ElvUI);
	local blizzardSkins = E and E.private and E.private.skins and E.private.skins.blizzard;
	if not (blizzardSkins and blizzardSkins.enable and blizzardSkins.achievement) then
		return;
	end
	local Skins = E.GetModule and E:GetModule("Skins", true);
	if Skins and Skins.HandleTab then
		Skins:HandleTab(tab);
	end
end

local function CreateTab()
	local index = 4;
	while _G["AchievementFrameTab" .. index] do -- another addon may have taken tab 4
		index = index + 1;
	end
	UI.tabIndex = index;

	local tab = CreateFrame("Button", "AchievementFrameTab" .. index, AchievementFrame, "AchievementFrameTabButtonTemplate");
	tab:SetID(index);
	tab:SetText("Remaining");
	tab:SetPoint("LEFT", _G["AchievementFrameTab" .. (index - 1)], "RIGHT", -5, 0);
	tab:SetScript("OnClick", function()
		UI.Activate();
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
	end);
	PanelTemplates_TabResize(tab, 30);
	ApplyElvUISkin(tab);
	UI.tab = tab;

	PanelTemplates_SetNumTabs(AchievementFrame, index);
	PanelTemplates_UpdateTabs(AchievementFrame);
end

local function InstallHooks()
	-- Blizzard's UpdateTabs only nudges the text of tabs 1-3.
	hooksecurefunc("AchievementFrame_UpdateTabs", function(clickedTab)
		local y = (clickedTab == UI.tabIndex) and -5 or -3;
		UI.tab.Text:SetPoint("CENTER", 0, y);
	end);

	-- Any Blizzard tab click deactivates us and restores the categories pane
	-- (which is not managed by AchievementFrame_ShowSubFrame). Comparison mode
	-- swaps the AchievementFrameTab_OnClick alias, so hook both named functions.
	hooksecurefunc("AchievementFrameBaseTab_OnClick", Deactivate);
	hooksecurefunc("AchievementFrameComparisonTab_OnClick", Deactivate);

	hooksecurefunc("AchievementFrame_SetComparisonTabs", function()
		PanelTemplates_HideTab(AchievementFrame, UI.tabIndex);
	end);
	hooksecurefunc("AchievementFrame_SetTabs", function()
		if not AchievementFrame.restrictedCategoryID then
			PanelTemplates_ShowTab(AchievementFrame, UI.tabIndex);
		end
	end);

	-- Tab visibility under restriction is already handled by
	-- PanelTemplates_SetAllTabsShown since our tab is registered; just make
	-- sure our panel yields to the restricted category view.
	hooksecurefunc("AchievementFrame_SetRestrictedMode", function(frame, restrictedCategoryID)
		if restrictedCategoryID then
			Deactivate();
		end
	end);
end

function UI.Setup()
	if UI.initialized then
		return;
	end
	UI.initialized = true;
	CreateTab();
	CreatePanel();
	InstallHooks();
end
