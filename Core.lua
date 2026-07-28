-- Core.lua: saved variables, achievement scanner, event loader.
local ADDON_NAME, RA = ...;

RA.FEAT_OF_STRENGTH_ID = 81;

-- How Feat-of-Strength obtainability is decided (single source of truth):
-- every FoS is hidden-until-earned and the game ships no obtainability data, so
-- a hidden FoS is listed only when it passes BOTH tiers --
--   1. NOT in RA.unobtainable (UnobtainableData.lua): the curated list of
--      removed/legacy feats that survive every automated filter.
--   2. IN the FoSData.lua allowlist as obtainable NOW: evergreen (`= true`)
--      always, or seasonal (`{season=N}`) only while season N is live.
-- IsObtainableFoS() below is the single function that answers this. FoS reach
-- the list only through the discovery pass; the visible walk never surfaces
-- them (all carry the hidden flag), so it skips FoS categories entirely.

-- Realm-first flag bits (Achievement.db2): permanently unobtainable. Used by
-- the non-FoS secret discovery filter (NOISE_FLAGS).
local REALM_FIRST_FLAGS = 0x100 + 0x200;

-- Manual escape hatch for obtainable hidden FoS the generator can't yet
-- classify (expired seasonal feats are byte-identical in the data to obtainable
-- ones, so the generator stays conservative). 61199/61200 "Solo Shuffle /
-- Battleground Blitz Medic: Midnight" are obtainable throughout the Midnight
-- expansion (desc says "during Midnight", no season) but live in the PvP
-- category the generator drops when no season is derivable. Evergreen for now;
-- revisit when Midnight ends.
local OBTAINABLE_HIDDEN_FOS = {
	[61199] = true, [61200] = true,
};

-- Live Mythic+ season number, matching the DisplaySeason.db2 "Season" column
-- that FoSData's seasonal keystone tags are keyed to. GetCurrentSeason returns
-- -1 until C_MythicPlus.RequestMapInfo (called on load) populates it; the
-- newMythicPlusSeason CVar is the immediate stopgap for that window. Returns
-- nil only if neither source is available.
-- CVar read via the modern C_CVar namespace (the global GetCVar is deprecated),
-- nil-safe.
local function GetCVarValue(name)
	return C_CVar and C_CVar.GetCVar and C_CVar.GetCVar(name);
end

local function GetEffectiveMythicPlusSeason()
	local season = C_MythicPlus and C_MythicPlus.GetCurrentSeason and C_MythicPlus.GetCurrentSeason();
	if season and season > 0 then
		return season;
	end
	local cvar = tonumber(GetCVarValue("newMythicPlusSeason"));
	if cvar and cvar > 0 then
		return cvar;
	end
	return nil;
end

-- The single obtainability authority for a hidden FoS (see the two-tier note at
-- the top of this file). Obtainable only if it is NOT on the removed list AND
-- has an obtainable entry (from FoSData.lua or the manual escape hatch): `true`
-- (evergreen, always) or {season = N} matching the live season. Resolving the
-- season at runtime means past seasons self-expire and a new season's feats
-- appear the moment the client reports it -- no regeneration needed for either.
local function IsObtainableFoS(id, currentSeason)
	if RA.unobtainable[id] then
		return false;
	end
	local entry = RA.obtainableHiddenFoS[id];
	if entry == nil then
		entry = OBTAINABLE_HIDDEN_FOS[id];
	end
	if entry == true then
		return true;
	end
	if type(entry) == "table" and entry.season then
		return currentSeason ~= nil and entry.season == currentSeason;
	end
	return false;
end

local defaults = {
	hidden = {},
	-- Per-faction remaining-list recordings; see RecordFactionSnapshot.
	factionRemaining = {},
	settings = {
		includeFoS = false,
		showHidden = false,
		includeSecret = false,
		includeMirror = false,
		-- Top-level category IDs the user has unchecked in the filter dropdown.
		-- Empty = show every category (the default). Keyed by top-level id.
		excludedCategories = {},
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

-- Top-level (root) category a given category rolls up to, cached. A root
-- category is one GetCategoryInfo reports with parent -1.
local topLevelCache = {};
local function GetTopLevelCategory(catID)
	if topLevelCache[catID] ~= nil then
		return topLevelCache[catID];
	end
	local top, id, hops = catID, catID, 0;
	while id and id ~= -1 and hops < 10 do
		local _, parentID = GetCategoryInfo(id);
		if parentID == nil or parentID == -1 then
			top = id;
			break
		end
		id = parentID;
		hops = hops + 1;
	end
	topLevelCache[catID] = top;
	return top;
end

-- Ordered top-level categories present in the live category list, minus Feats
-- of Strength (it has its own toggle). Powers the category filter dropdown.
function RA.GetTopLevelCategories()
	local result, seen = {}, {};
	for _, catID in ipairs(GetCategoryList()) do
		local top = GetTopLevelCategory(catID);
		if top and not seen[top] and not IsFeatOfStrengthCategory(top) then
			seen[top] = true;
			local name = GetCategoryInfo(top);
			result[#result + 1] = { id = top, name = name or ("Category " .. top) };
		end
	end
	return result;
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
	-- opposite-faction dedup: a same-name achievement on our side (earned or
	-- not) means the opposite-faction copy is the same achievement, not a
	-- distinct one like Seasoned Hunter Akana / Seasoned Poen Gillbrack.
	local seen, highestID = {}, 0;
	local visibleNames = includeMirror and {} or nil;
	local snapshotIds = {};
	local excludedCats = RA.db.settings.excludedCategories;
	for _, catID in ipairs(GetCategoryList()) do
		-- FoS categories are skipped here: every FoS is hidden-until-earned, so
		-- this walk never surfaces an unearned one -- they come solely from the
		-- discovery pass below (IsObtainableFoS). Skipping them also keeps FoS
		-- out of the opposite-faction snapshot.
		if not IsFeatOfStrengthCategory(catID)
				and not excludedCats[GetTopLevelCategory(catID)] then
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
				local id, name, points, completed, _, _, _, description = GetAchievementInfo(catID, i);
				if id and not completed and not RA.unobtainable[id] then
					if visibleNames and name then
						visibleNames[name] = true;
					end
					seen[id] = true;
					snapshotIds[#snapshotIds + 1] = id;
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
						if chainID and not seen[chainID] and not chainCompleted then
							if visibleNames and chainName then
								visibleNames[chainName] = true;
							end
							seen[chainID] = true;
							snapshotIds[#snapshotIds + 1] = chainID;
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
		-- Resolved once per scan; seasonal FoS tags compare against it.
		local currentMythicSeason = GetEffectiveMythicPlusSeason();
		for candidate = 1, maxID do
			local lockedTo = RA.factionLocked[candidate];
			if not seen[candidate] and not RA.unobtainable[candidate]
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
					-- A FoS subcategory that is empty for THIS character (e.g. the
					-- seasonal keystone bucket, FoS > Dungeons, when none are earned)
					-- is absent from GetCategoryList, so the visibleCats gate -- which
					-- exists only to keep the retired "Legacy" tree out of the secret
					-- path -- would wrongly drop obtainable hidden FoS living there.
					-- FoS is gated by the allowlist (IsObtainableFoS) instead, and is
					-- never under Legacy, so for FoS we only require a real FoS category.
					local isFoSCat = catID and IsFeatOfStrengthCategory(catID);
					if catID and (visibleCats[catID] or isFoSCat) and not excludedCats[GetTopLevelCategory(catID)] then
						if isFoSCat then
							wanted = includeFoS and IsObtainableFoS(id, currentMythicSeason);
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
						local mcatOK, mcat = pcall(GetAchievementCategory, id);
						if not (mcatOK and mcat and excludedCats[GetTopLevelCategory(mcat)]) then
							results[#results + 1] = {
								id = id,
								mirror = mirrorCode,
								name = name,
								points = points,
								searchText = (name .. " " .. (description or "")):lower(),
							};
						end
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
			-- GetCurrentSeason returns -1 until this populates; request it early
			-- so seasonal FoS resolve correctly by the time the tab is opened.
			-- There is no public "season loaded" event, so the newMythicPlusSeason
			-- CVar covers the brief window (see GetEffectiveMythicPlusSeason), and
			-- the deferred refresh below corrects a tab left open across the load.
			if C_MythicPlus and C_MythicPlus.RequestMapInfo then
				C_MythicPlus.RequestMapInfo();
				C_Timer.After(3, function()
					if RA.db and RA.UI.IsShown() then
						RA.InvalidateCache();
						RA.UI.Refresh();
					end
				end);
			end
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

-- /raseason -- diagnostic for the FoS seasonal resolver: prints the raw API
-- season, the CVar stopgap, and the effective season used to decide which
-- seasonal Feats of Strength are obtainable.
SLASH_RASEASON1 = "/raseason";
SlashCmdList["RASEASON"] = function()
	local raw = C_MythicPlus and C_MythicPlus.GetCurrentSeason and C_MythicPlus.GetCurrentSeason();
	local cvar = GetCVarValue("newMythicPlusSeason");
	local eff = GetEffectiveMythicPlusSeason();
	local source = eff and ((raw and raw > 0) and " (from GetCurrentSeason)" or " (from CVar stopgap)") or " (unknown)";
	print("|cff33ff99RemainingAchievements|r seasonal FoS diagnostic:");
	print("  C_MythicPlus.GetCurrentSeason() = " .. tostring(raw));
	print("  newMythicPlusSeason CVar        = " .. tostring(cvar));
	print("  effective season for FoS        = " .. tostring(eff) .. source);
end

-- /radiagnose [achievementID] -- diagnostic for bug reports, shown in a
-- copy-paste dialog (same Cmd/Ctrl+C flow as the export box). No argument:
-- client + season + FoS-list summary. With an achievement id: a full trace of
-- why that achievement does or doesn't land in the FoS list.
local function DiagnoseAchievement(add, id)
	add("achievement", id);
	local isValid = C_AchievementInfo and C_AchievementInfo.IsValidAchievement
		and C_AchievementInfo.IsValidAchievement(id);
	add("isValidAchievement", tostring(isValid));
	local ok, rid, name, points, completed, _, _, _, _, flags, _, _, isGuild, _, _, isStatistic = pcall(GetAchievementInfo, id);
	if not ok or not rid then
		add("GetAchievementInfo", "no data (invalid or not loaded)");
		return;
	end
	add("name", tostring(name));
	add("points", tostring(points), "completed", tostring(completed),
		"guild", tostring(isGuild), "statistic", tostring(isStatistic));
	add("flags", string.format("0x%x", flags or 0));
	local catOK, cat = pcall(GetAchievementCategory, id);
	cat = catOK and cat or nil;
	add("category", tostring(cat), "isFoSCategory", tostring(cat and IsFeatOfStrengthCategory(cat)));
	add("factionLocked", tostring(RA.factionLocked and RA.factionLocked[id]),
		"playerFaction", tostring(UnitFactionGroup("player")));
	add("inUnobtainable", tostring(RA.unobtainable[id] == true));
	local entry = RA.obtainableHiddenFoS[id];
	if entry == nil then entry = OBTAINABLE_HIDDEN_FOS[id]; end
	local entryDesc = entry == true and "evergreen (true)"
		or (type(entry) == "table" and entry.season and ("seasonal {season=" .. entry.season .. "}"))
		or "not in allowlist";
	add("allowlistEntry", entryDesc);
	local cur = GetEffectiveMythicPlusSeason();
	add("effectiveSeason", tostring(cur), "isObtainableFoS", tostring(IsObtainableFoS(id, cur)));
end

-- Shared builder: the full diagnostic text for a bug report. Reused by
-- /radiagnose and by the per-row report flag (RA.ShowReport). Kept English on
-- purpose -- the maintainer reads these, not the reporter (same as the export
-- headers). Pass an id for a full per-achievement trace, or nil for the summary.
local function BuildDiagnostic(id)
	local lines = {};
	local function add(...) lines[#lines + 1] = table.concat({...}, "|"); end
	add("addonVersion", C_AddOns and C_AddOns.GetAddOnMetadata
		and C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version") or "?");
	add("client", (GetBuildInfo()), "interface", tostring((select(4, GetBuildInfo()))));
	add("locale", GetLocale());
	local raw = C_MythicPlus and C_MythicPlus.GetCurrentSeason and C_MythicPlus.GetCurrentSeason();
	add("mplusSeasonRaw", tostring(raw), "cvar", tostring(GetCVarValue("newMythicPlusSeason")),
		"effective", tostring(GetEffectiveMythicPlusSeason()));
	add("arenaSeason", tostring(GetCurrentArenaSeason and GetCurrentArenaSeason()),
		"prevArena", tostring(GetPreviousArenaSeason and GetPreviousArenaSeason()));
	add("faction", tostring(UnitFactionGroup("player")),
		"achievementUILoaded", tostring(C_AddOns.IsAddOnLoaded("Blizzard_AchievementUI")));
	-- FoS allowlist composition + how many resolve obtainable right now.
	local cur = GetEffectiveMythicPlusSeason();
	local ever, seasonal, obtainableNow = 0, 0, 0;
	for _, v in pairs(RA.obtainableHiddenFoS) do
		if v == true then
			ever = ever + 1; obtainableNow = obtainableNow + 1;
		elseif type(v) == "table" and v.season then
			seasonal = seasonal + 1;
			if v.season == cur then obtainableNow = obtainableNow + 1; end
		end
	end
	add("fosAllowlist", "evergreen", ever, "seasonal", seasonal,
		"obtainableAtSeason", tostring(cur), "count", obtainableNow);
	add("settings", "includeFoS", tostring(RA.db and RA.db.settings.includeFoS),
		"includeSecret", tostring(RA.db and RA.db.settings.includeSecret));
	if id then
		DiagnoseAchievement(add, id);
	else
		add("hint", "run /radiagnose <id> to trace a specific achievement");
	end
	return table.concat(lines, "\n");
end

local function ShowText(title, text)
	if RA.ShowCopyDialog then
		RA.ShowCopyDialog(title, text);
	else
		print(text); -- fallback if the dialog isn't available
	end
end

SLASH_RADIAGNOSE1 = "/radiagnose";
SlashCmdList["RADIAGNOSE"] = function(msg)
	local id = tonumber((msg or ""):match("%d+"));
	ShowText("Remaining Achievements - Diagnostic", BuildDiagnostic(id));
end

-- Feedback plumbing. Report/feedback bodies stay English (bug reports for the
-- maintainer); the row flag's tooltip is the only user-facing part and is
-- localized in UI.lua.
local ISSUES_URL = "https://github.com/nerolabs/RemainingAchievements/issues";
local CF_URL = "https://www.curseforge.com/wow/addons/remaining-achievements";

-- Per-row "report this achievement" flag (shown only on FoS/hidden rows, where
-- obtainability is derived and a "shouldn't be here / is missing" report is
-- actionable). Bundles the full diagnostic so reports arrive ready to triage.
function RA.ShowReport(id)
	local header = "Feat of Strength / hidden achievement that looks wrong -- listed but not "
		.. "actually obtainable, or missing when it should show?\n"
		.. "Open a new issue and paste all of this in (add a line on what's wrong):\n"
		.. ISSUES_URL .. "\n"
		.. string.rep("-", 50) .. "\n";
	ShowText("Remaining Achievements - Report", header .. BuildDiagnostic(id));
end

SLASH_RAFEEDBACK1 = "/rafeedback";
SlashCmdList["RAFEEDBACK"] = function()
	local body = "Remaining Achievements -- feedback & bug reports\n\n"
		.. "GitHub issues (best for bugs): " .. ISSUES_URL .. "\n"
		.. "CurseForge comments: " .. CF_URL .. "\n\n"
		.. "Tip: for a Feat of Strength or hidden achievement that shouldn't be listed "
		.. "(or is missing), click the flag on its row -- it builds a ready-to-paste report.";
	ShowText("Remaining Achievements - Feedback", body);
end
