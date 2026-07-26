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
-- (remaining/points always exclude hidden, regardless of the toggle).
-- Empty until the first scan completes.
function UI.GetDisplayEntries()
	local showHidden = RA.db.settings.showHidden;
	local entries, remaining, points, hiddenCount = {}, 0, 0, 0;
	for _, entry in ipairs(RA.GetRemaining() or {}) do
		local isHidden = RA.IsHidden(entry.id);
		if isHidden then
			hiddenCount = hiddenCount + 1;
		else
			remaining = remaining + 1;
			points = points + entry.points;
		end
		if (showHidden or not isHidden) and (not searchText or entry.searchText:find(searchText, 1, true)) then
			entries[#entries + 1] = entry;
		end
	end
	return entries, remaining, points, hiddenCount;
end

local function UpdateCountsDisplay(remaining, points, hiddenCount)
	controls.CountText:SetText(BreakUpLargeNumbers(remaining) .. " remaining");
	controls.PointsText:SetText(BreakUpLargeNumbers(points) .. " points unearned");
	controls.ShowHiddenLabel:SetText(("Show hidden (%d)"):format(hiddenCount));
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
		-- Scan pending: only announce it when there are no (stale) rows to
		-- keep showing; either way this re-runs once the scan lands.
		local dataProvider = scrollBox:GetDataProvider();
		list.LoadingText:SetShown(not dataProvider or dataProvider:GetSize() == 0);
		RA.RequestRemaining(OnScanComplete);
		return;
	end
	list.LoadingText:Hide();
	local entries, remaining, points, hiddenCount = UI.GetDisplayEntries();
	local selected = selectionBehavior:GetFirstSelectedElementData();
	local selectedID = selected and selected.id;
	local elements = {};
	for i, entry in ipairs(entries) do
		-- category/index feed CalculateSelectedHeight, which lacks Init's
		-- by-id fallback; including them routes both through the same
		-- GetAchievementInfo(cat, i) lookup Blizzard's own list uses.
		elements[i] = { id = entry.id, category = entry.category, index = entry.index };
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
	UpdateCountsDisplay(remaining, points, hiddenCount);
end

-- [[ Row behavior ]] --

local function UpdateRowHiddenState(button)
	local isHidden = RA.IsHidden(button.id);
	button:SetAlpha(isHidden and 0.45 or 1);
	local hideButton = button.RAHideButton;
	if isHidden then
		hideButton:SetNormalTexture("Interface\\Buttons\\UI-RefreshButton");
		hideButton.tooltipText = "Restore to Remaining list";
	else
		hideButton:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up");
		hideButton.tooltipText = "Hide from Remaining list";
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
			rootDescription:CreateButton("Restore to list", function()
				RA.SetHidden(id, false);
				UI.Refresh();
			end);
		else
			rootDescription:CreateButton("Hide from list", function()
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

	local fosCheck = CreateFrame("CheckButton", nil, controls, "UICheckButtonTemplate");
	fosCheck:SetSize(26, 26);
	fosCheck:SetPoint("TOPLEFT", 8, -96);
	fosCheck:SetChecked(RA.db.settings.includeFoS);
	fosCheck:SetScript("OnClick", function(self)
		RA.db.settings.includeFoS = self:GetChecked() and true or false;
		RA.InvalidateCache();
		UI.Refresh();
	end);
	local fosLabel = controls:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall");
	fosLabel:SetPoint("LEFT", fosCheck, "RIGHT", 2, 0);
	fosLabel:SetPoint("RIGHT", controls, "RIGHT", -8, 0);
	fosLabel:SetJustifyH("LEFT");
	fosLabel:SetText("Include Feats of Strength");

	local hiddenCheck = CreateFrame("CheckButton", nil, controls, "UICheckButtonTemplate");
	hiddenCheck:SetSize(26, 26);
	hiddenCheck:SetPoint("TOPLEFT", fosCheck, "BOTTOMLEFT", 0, -4);
	hiddenCheck:SetChecked(RA.db.settings.showHidden);
	hiddenCheck:SetScript("OnClick", function(self)
		RA.db.settings.showHidden = self:GetChecked() and true or false;
		UI.Refresh();
	end);
	controls.ShowHiddenLabel = controls:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall");
	controls.ShowHiddenLabel:SetPoint("LEFT", hiddenCheck, "RIGHT", 2, 0);
	controls.ShowHiddenLabel:SetPoint("RIGHT", controls, "RIGHT", -8, 0);
	controls.ShowHiddenLabel:SetJustifyH("LEFT");
	controls.ShowHiddenLabel:SetText("Show hidden (0)");

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

	list.LoadingText = list:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
	list.LoadingText:SetPoint("CENTER");
	list.LoadingText:SetText("Crunching achievements...");
	list.LoadingText:Hide();

	local view = CreateScrollBoxListLinearView();
	view:SetElementExtentCalculator(function(dataIndex, elementData)
		if SelectionBehaviorMixin.IsElementDataIntrusiveSelected(elementData) then
			return AchievementTemplateMixin.CalculateSelectedHeight(elementData);
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
