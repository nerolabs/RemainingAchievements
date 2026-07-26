-- Core.lua: saved variables, achievement scanner, event loader.
local ADDON_NAME, RA = ...;

RA.FEAT_OF_STRENGTH_ID = 81;

-- FoS subcategories that are retired-content classes rather than earnable
-- feats (verified against the Achievement_Category.db2 export): Promotions
-- (Collector's Editions, TCG, ended promos), Player vs. Player (old
-- gladiator/seasonal titles), Events (one-time world events). The game ships
-- no obtainability data, so "obtainable FoS" = the FoS tree minus these,
-- minus realm-firsts, minus UNOBTAINABLE.
local RETIRED_FOS_CATEGORIES = {
	[15268] = true, -- Promotions
	[15270] = true, -- Player vs. Player
	[15274] = true, -- Events
};

-- Realm-first flag bits (Achievement.db2): permanently unobtainable.
local REALM_FIRST_FLAGS = 0x100 + 0x200;

-- Retired/never-shipped content that survives every data filter (visible
-- category, no distinguishing flag — verified against the Achievement.db2
-- export). Curated from tester reports.
-- 7268/7269/7270: Temple of Kotmogu scenario, removed in MoP beta.
-- 416: Scarab Lord (AQ gate opening; FoS > Mounts is otherwise obtainable).
local UNOBTAINABLE = {
	[7268] = true, [7269] = true, [7270] = true,
	[416] = true,
};

-- Every FoS achievement is hidden-until-earned, and expired seasonal feats
-- are byte-identical in the data to obtainable ones (verified: Stress Test
-- CN Realms carries exactly Ratts' Revenge's flags and category, expired vs.
-- active season keystone rows match completely). So obtainable FoS comes
-- from the generated FoSData.lua allowlist (evergreen + current season);
-- this table is the manual escape hatch for additions between regenerations.
local OBTAINABLE_HIDDEN_FOS = {};

local defaults = {
	hidden = {},
	-- Per-faction remaining-list recordings; see RecordFactionSnapshot.
	factionRemaining = {},
	settings = {
		includeFoS = false,
		showHidden = false,
		includeSecret = false,
		includeMirror = false,
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

-- Every completed scan records this faction's plain remaining list (no FoS,
-- no discovery extras, chains included) so a character of the other faction
-- can replay it as the "opposite faction" view. The recording faction's own
-- client did the faction filtering natively, which no API heuristic can.
local function RecordFactionSnapshot(ids)
	local faction = UnitFactionGroup("player");
	if faction ~= "Alliance" and faction ~= "Horde" then
		return;
	end
	RA.db.factionRemaining[faction] = {
		ids = ids,
		character = UnitName("player") .. "-" .. GetRealmName(),
		when = time(),
	};
end

-- The recorded list for the faction opposite the current character, or nil.
function RA.GetOppositeSnapshot()
	local faction = UnitFactionGroup("player");
	local other = (faction == "Alliance" and "Horde") or (faction == "Horde" and "Alliance") or nil;
	return other and RA.db.factionRemaining[other] or nil, other;
end

-- Cached array of incomplete (account-wide) achievements:
-- { id, category, index, name, points, searchText }. category/index are the
-- GetAchievementInfo(cat, i) coordinates from scan time — kept because
-- AchievementTemplateMixin.CalculateSelectedHeight only supports that form
-- (Init has a by-id fallback; the height calculator does not). They go stale
-- when an achievement is earned, so any earn invalidates the whole cache.
-- Later steps of a progressive chain have no list coordinates and carry no
-- index (the UI sizes those by id). Hidden filtering happens at display time.
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
	local includeSecret = RA.db.settings.includeSecret;
	local includeMirror = RA.db.settings.includeMirror;
	local processed = 0;
	-- seen/highestID feed the discovery pass below. visibleNames powers the
	-- mirror dedup: a same-name achievement on our side (earned or not) means
	-- the opposite-faction copy is the same achievement, not a true mirror
	-- like Seasoned Hunter Akana / Seasoned Poen Gillbrack.
	local seen, highestID = {}, 0;
	local visibleNames = includeMirror and {} or nil;
	local snapshotIds = {};
	for _, catID in ipairs(GetCategoryList()) do
		local catIsFoS = IsFeatOfStrengthCategory(catID);
		if not catIsFoS or (includeFoS and not RETIRED_FOS_CATEGORIES[catID]) then
			-- The client lists each category's completed achievements first;
			-- Blizzard's Incomplete filter relies on that ordering, so only
			-- the incomplete tail needs visiting.
			local total, _, numIncomplete = GetCategoryNumAchievements(catID);
			if visibleNames then
				-- The completed head this loop otherwise skips.
				for i = 1, total - numIncomplete do
					local _, headName = GetAchievementInfo(catID, i);
					if headName then
						visibleNames[headName] = true;
					end
					processed = processed + 1;
					if processed % 50 == 0 then
						coroutine.yield();
					end
				end
			end
			for i = total - numIncomplete + 1, total do
				local id, name, points, completed, _, _, _, description, flags = GetAchievementInfo(catID, i);
				if id and not completed and not UNOBTAINABLE[id]
						and (not catIsFoS or bit.band(flags or 0, REALM_FIRST_FLAGS) == 0) then
					if visibleNames and name then
						visibleNames[name] = true;
					end
					seen[id] = true;
					if not catIsFoS then
						snapshotIds[#snapshotIds + 1] = id;
					end
					if id > highestID then
						highestID = id;
					end
					results[#results + 1] = {
						id = id,
						category = catID,
						index = i,
						name = name or "",
						points = points or 0,
						searchText = ((name or "") .. " " .. (description or "")):lower(),
					};
					-- The category list omits later steps of a progressive
					-- chain until the current step completes, so walk the
					-- chain forward to pick them up (e.g. "Algari Delver II"
					-- while "Algari Delver" is still unfinished).
					local nextID = GetNextAchievement(id);
					local hops = 0;
					while nextID and hops < 50 do
						local chainID, chainName, chainPoints, chainCompleted, _, _, _, chainDescription = GetAchievementInfo(nextID);
						if chainID and not chainCompleted then
							if visibleNames and chainName then
								visibleNames[chainName] = true;
							end
							seen[chainID] = true;
							if not catIsFoS then
								snapshotIds[#snapshotIds + 1] = chainID;
							end
							if chainID > highestID then
								highestID = chainID;
							end
							results[#results + 1] = {
								id = chainID,
								category = catID,
								name = chainName or "",
								points = chainPoints or 0,
								searchText = ((chainName or "") .. " " .. (chainDescription or "")):lower(),
							};
						end
						nextID = GetNextAchievement(nextID);
						hops = hops + 1;
						processed = processed + 1;
						if processed % 50 == 0 then
							coroutine.yield();
						end
					end
				end
				processed = processed + 1;
				if processed % 50 == 0 then
					coroutine.yield();
				end
			end
		end
	end
	if includeSecret or includeFoS then
		-- Beta: discovery pass for achievements the category UI never lists.
		-- Brute-force the ID space and diff against what the walk above saw.
		-- The ceiling rides on the highest visible ID so it tracks patches.
		-- Hits are routed by toggle below: point-carrying secrets belong to
		-- the secret toggle, hidden Feats of Strength (0-point, e.g. Ratts'
		-- Revenge) to the FoS toggle.
		local maxID = math.max(60000, highestID + 20000);
		local IsValidAchievement = C_AchievementInfo and C_AchievementInfo.IsValidAchievement;
		-- Opposite-faction achievements are the biggest noise source: the UI
		-- hides them exactly like secrets, and the API exposes no faction, so
		-- FactionData.lua carries a generated table. Neutral (starter pandaren)
		-- matches neither faction and gets no faction-locked entries.
		local playerFaction = UnitFactionGroup("player");
		local myFactionCode = (playerFaction == "Horde" and RA.FACTION_HORDE)
			or (playerFaction == "Alliance" and RA.FACTION_ALLIANCE);
		-- Achievement.db2 flag bits, verified against the wago.tools export:
		-- 0x100/0x200 realm-firsts (no longer earnable), 0x100000 internal
		-- tracking copies ("<DND>", "char specific hidden copy"), 0x1000000
		-- client-internal launch/login entries ("[DNT]").
		local NOISE_FLAGS = REALM_FIRST_FLAGS + 0x100000 + 0x1000000;
		-- Retired content (old PvP titles/seasons, removed raid titles,
		-- pre-Cata professions) lives in the "Legacy" category tree, which
		-- GetCategoryList never returns; real secrets sit inside normally
		-- listed categories. So: no listed category, no listing.
		local visibleCats = {};
		for _, catID in ipairs(GetCategoryList()) do
			visibleCats[catID] = true;
		end
		for candidate = 1, maxID do
			local lockedTo = RA.factionLocked[candidate];
			if not seen[candidate] and not UNOBTAINABLE[candidate]
					and (lockedTo == nil or lockedTo == myFactionCode)
					and (not IsValidAchievement or IsValidAchievement(candidate)) then
				local ok, id, name, points, completed, _, _, _, description, flags, _, _, isGuild, _, _, isStatistic = pcall(GetAchievementInfo, candidate);
				if ok and id and not completed and not isGuild and not isStatistic
						and bit.band(flags or 0, NOISE_FLAGS) == 0
						and name and name ~= "" then
					local catOK, catID = pcall(GetAchievementCategory, id);
					catID = (catOK and catID) or nil;
					-- Real secrets carry achievement points (user rule); hidden
					-- FoS entries ride the FoS toggle instead. 0-point hidden
					-- entries outside FoS are dropped as noise.
					local wanted = false;
					if catID and visibleCats[catID] then
						if IsFeatOfStrengthCategory(catID) then
							wanted = includeFoS and (RA.obtainableHiddenFoS[id] == true or OBTAINABLE_HIDDEN_FOS[id] == true);
						else
							wanted = includeSecret and points ~= nil and points > 0;
						end
					end
					if wanted then
						results[#results + 1] = {
							id = id,
							category = catID,
							secret = true,
							name = name,
							points = points or 0,
							searchText = (name .. " " .. (description or "")):lower(),
						};
					end
				end
			end
			processed = processed + 1;
			if processed % 200 == 0 then
				coroutine.yield();
			end
		end
	end
	if includeMirror then
		-- Opposite-faction view, DataForAzeroth style: replay the remaining
		-- list a character of the other faction recorded (their client did
		-- the faction filtering natively), minus anything our side already
		-- covers — same id (shared achievement), same name (the other
		-- faction's copy of one achievement, e.g. Master of Isle of
		-- Conquest), earned account-wide since the recording — and only
		-- point-carrying entries.
		local snapshot, otherFaction = RA.GetOppositeSnapshot();
		if snapshot and snapshot.ids then
			local mirrorCode = (otherFaction == "Horde") and RA.FACTION_HORDE or RA.FACTION_ALLIANCE;
			for _, snapID in ipairs(snapshot.ids) do
				if not seen[snapID] then
					local ok, id, name, points, completed, _, _, _, description = pcall(GetAchievementInfo, snapID);
					if ok and id and not completed and points and points > 0
							and name and name ~= "" and not visibleNames[name] then
						results[#results + 1] = {
							id = id,
							mirror = mirrorCode,
							name = name,
							points = points,
							searchText = (name .. " " .. (description or "")):lower(),
						};
					end
				end
				processed = processed + 1;
				if processed % 100 == 0 then
					coroutine.yield();
				end
			end
		end
	end
	return results, snapshotIds;
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
		local ok, results, snapshotIds = coroutine.resume(scanCo);
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
			RecordFactionSnapshot(snapshotIds);
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
