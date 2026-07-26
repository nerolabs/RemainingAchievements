-- Core.lua: saved variables, achievement scanner, event loader.
local ADDON_NAME, RA = ...;

RA.FEAT_OF_STRENGTH_ID = 81;

local defaults = {
	hidden = {},
	settings = {
		includeFoS = false,
		showHidden = false,
	},
};

local function ApplyDefaults(src, dst)
	if type(dst) ~= "table" then
		dst = {};
	end
	for k, v in pairs(src) do
		if type(v) == "table" then
			dst[k] = ApplyDefaults(v, dst[k]);
		elseif dst[k] == nil then
			dst[k] = v;
		end
	end
	return dst;
end

-- Feats of Strength: category 81 or any category whose parent chain reaches it.
local fosCache = {};
local function IsFeatOfStrengthCategory(catID)
	if fosCache[catID] ~= nil then
		return fosCache[catID];
	end
	local isFoS = false;
	local visited = {};
	local id, hops = catID, 0;
	while id and id ~= -1 and hops < 10 do
		if fosCache[id] ~= nil then
			isFoS = fosCache[id];
			break
		end
		if id == RA.FEAT_OF_STRENGTH_ID then
			isFoS = true;
			break
		end
		visited[#visited + 1] = id;
		local _, parentID = GetCategoryInfo(id);
		id = parentID;
		hops = hops + 1;
	end
	fosCache[catID] = isFoS;
	for _, seen in ipairs(visited) do
		fosCache[seen] = isFoS;
	end
	return isFoS;
end

-- Cached array of incomplete (account-wide) achievements:
-- { id, category, index, name, points, searchText }. category/index are the
-- GetAchievementInfo(cat, i) coordinates from scan time — kept because
-- AchievementTemplateMixin.CalculateSelectedHeight only supports that form
-- (Init has a by-id fallback; the height calculator does not). They go stale
-- when an achievement is earned, so any earn invalidates the whole cache.
-- Hidden filtering happens at display time.
local remainingCache;
local pendingCallbacks = {};
local scanner = CreateFrame("Frame");
scanner:Hide();
local scanCo;

function RA.InvalidateCache()
	remainingCache = nil;
	scanCo = nil; -- abandon any scan in progress; OnUpdate restarts it if callbacks are waiting
end

-- nil until a scan has completed.
function RA.GetRemaining()
	return remainingCache;
end

-- Coroutine body: yields every 50 achievements so the scanner can spread
-- the full scan across frames instead of freezing on tab open.
local function BuildRemaining()
	local results = {};
	local includeFoS = RA.db.settings.includeFoS;
	local processed = 0;
	for _, catID in ipairs(GetCategoryList()) do
		if includeFoS or not IsFeatOfStrengthCategory(catID) then
			-- The client lists each category's completed achievements first;
			-- Blizzard's Incomplete filter relies on that ordering, so only
			-- the incomplete tail needs visiting.
			local total, _, numIncomplete = GetCategoryNumAchievements(catID);
			for i = total - numIncomplete + 1, total do
				local id, name, points, completed, _, _, _, description = GetAchievementInfo(catID, i);
				if id and not completed then
					results[#results + 1] = {
						id = id,
						category = catID,
						index = i,
						name = name or "",
						points = points or 0,
						searchText = ((name or "") .. " " .. (description or "")):lower(),
					};
				end
				processed = processed + 1;
				if processed % 50 == 0 then
					coroutine.yield();
				end
			end
		end
	end
	return results;
end

scanner:SetScript("OnUpdate", function()
	if remainingCache or #pendingCallbacks == 0 then
		scanCo = nil;
		scanner:Hide();
		return;
	end
	if not scanCo then
		scanCo = coroutine.create(BuildRemaining);
	end
	local deadline = debugprofilestop() + 5; -- ms of scan work per frame
	while debugprofilestop() < deadline do
		local ok, results = coroutine.resume(scanCo);
		if not ok then
			-- results holds the error; drop the callbacks or this restarts forever
			scanCo = nil;
			pendingCallbacks = {};
			scanner:Hide();
			geterrorhandler()(results);
			return;
		elseif results then
			scanCo = nil;
			remainingCache = results;
			local callbacks = pendingCallbacks;
			pendingCallbacks = {};
			scanner:Hide();
			for _, callback in ipairs(callbacks) do
				callback();
			end
			return;
		end
	end
end);

-- Runs callback once the remaining list is available, scanning asynchronously
-- if needed. Returns true when the result was already cached (callback has
-- run before this returns).
function RA.RequestRemaining(callback)
	if remainingCache then
		callback();
		return true;
	end
	for _, existing in ipairs(pendingCallbacks) do
		if existing == callback then
			return false;
		end
	end
	pendingCallbacks[#pendingCallbacks + 1] = callback;
	scanner:Show();
	return false;
end

function RA.IsHidden(id)
	return RA.db.hidden[id] == true;
end

function RA.SetHidden(id, hidden)
	RA.db.hidden[id] = hidden and true or nil;
end

local loader = CreateFrame("Frame");
loader:RegisterEvent("ADDON_LOADED");
loader:RegisterEvent("ACHIEVEMENT_EARNED");
loader:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" then
		if arg1 == ADDON_NAME then
			RemainingAchievementsDB = ApplyDefaults(defaults, RemainingAchievementsDB);
			RA.db = RemainingAchievementsDB;
			if C_AddOns.IsAddOnLoaded("Blizzard_AchievementUI") then
				RA.UI.Setup();
			end
		elseif arg1 == "Blizzard_AchievementUI" and RA.db then
			RA.UI.Setup();
		end
	elseif event == "ACHIEVEMENT_EARNED" then
		-- Earning shifts by-index positions within the category and can reveal
		-- the next step of a progressive chain, so a full rescan is the only
		-- safe refresh; the UI keeps its scroll position across it.
		RA.InvalidateCache();
		if RA.UI.IsShown() then
			RA.UI.Refresh();
		end
	end
end);
