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
	local id, hops = catID, 0;
	while id and id ~= -1 and hops < 10 do
		if id == RA.FEAT_OF_STRENGTH_ID then
			isFoS = true;
			break
		end
		local _, parentID = GetCategoryInfo(id);
		id = parentID;
		hops = hops + 1;
	end
	fosCache[catID] = isFoS;
	return isFoS;
end

local remainingCache;

function RA.InvalidateCache()
	remainingCache = nil;
end

-- Cached array of incomplete (account-wide) achievements:
-- { id, name, points, searchText }. Hidden filtering happens at display time.
function RA.GetRemaining()
	if remainingCache then
		return remainingCache;
	end
	remainingCache = {};
	local includeFoS = RA.db.settings.includeFoS;
	for _, catID in ipairs(GetCategoryList()) do
		if includeFoS or not IsFeatOfStrengthCategory(catID) then
			for i = 1, GetCategoryNumAchievements(catID) do
				local id, name, points, completed, _, _, _, description = GetAchievementInfo(catID, i);
				if id and not completed then
					remainingCache[#remainingCache + 1] = {
						id = id,
						name = name or "",
						points = points or 0,
						searchText = ((name or "") .. " " .. (description or "")):lower(),
					};
				end
			end
		end
	end
	return remainingCache;
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
		-- Earning a step can also reveal the next step of a progressive chain,
		-- so a lazy full rescan beats removing just this one id.
		RA.InvalidateCache();
		if RA.UI.IsShown() then
			RA.UI.Refresh();
		end
	end
end);
