#!/usr/bin/env lua
-- Regression guard for FoSData.lua + the seasonal FoS resolver.
-- Run from the repo root:  lua tools/test-fos.lua   (exit 0 = pass)
-- Season TAGS are permanent facts (an achievement's season never changes), so
-- they make stable assertions that catch accidental generator breakage: a
-- dropped feat, a mis-tag, or an evergreen feat wrongly made seasonal.

local failures = 0
local function check(label, got, want)
	if got ~= want then
		failures = failures + 1
		print(string.format("FAIL  %-52s got=%s want=%s", label, tostring(got), tostring(want)))
	else
		print("pass  " .. label)
	end
end

-- Load the generated table into a fake addon namespace.
local RA = {}
local chunk = assert(loadfile("FoSData.lua"))
chunk("RemainingAchievements", RA)
local fos = assert(RA.obtainableHiddenFoS, "FoSData did not set RA.obtainableHiddenFoS")

-- 1. Structure: every entry is `true` or `{season = <positive int>}`.
local structOK, total, seasonal = true, 0, 0
for id, v in pairs(fos) do
	total = total + 1
	if v == true then
		-- evergreen, fine
	elseif type(v) == "table" and type(v.season) == "number"
			and v.season > 0 and v.season == math.floor(v.season) then
		seasonal = seasonal + 1
	else
		structOK = false
		print(string.format("FAIL  malformed entry [%s] = %s", tostring(id), tostring(v)))
	end
end
check("all entries well-formed (true or {season=int})", structOK, true)
print(string.format("info  %d feats total, %d seasonal, %d evergreen", total, seasonal, total - seasonal))

-- 2. Known-stable tags (these ids and seasons are historical facts).
local function tag(id)
	local v = fos[id]
	if v == true then return "true" end
	if type(v) == "table" and v.season then return v.season end
	return nil
end
check("Warglaives of Azzinoth 426 = evergreen", tag(426), "true")
check("Thunderfury 428 = evergreen", tag(428), "true")
check("TWW S1 Keystone Explorer 20523 = season 13", tag(20523), 13)
check("Midnight S1 Keystone Master 61256 = season 17", tag(61256), 17)
check("Midnight S2 Keystone Master 62447 = season 18", tag(62447), 18)
check("Midnight S1 Gladiator 61188 = season 17", tag(61188), 17)
check("AotC: Crown of the Cosmos 61624 = season 17", tag(61624), 17)
check("AotC: Ula'tek 63650 = season 18", tag(63650), 18)
check("expired Fated Nathria 15665 absent", fos[15665], nil)
check("old Gladiator 6002 (title-less PvP) absent", fos[6002], nil)

-- 3. Resolver logic (mirror of Core.lua IsObtainableFoS).
local function isObtainable(id, currentSeason)
	local e = fos[id]
	if e == true then return true end
	if type(e) == "table" and e.season then
		return currentSeason ~= nil and e.season == currentSeason
	end
	return false
end
check("evergreen obtainable at any season", isObtainable(426, 17), true)
check("evergreen obtainable even at nil season", isObtainable(426, nil), true)
check("season-17 feat obtainable at 17", isObtainable(61256, 17), true)
check("season-17 feat hidden at 18", isObtainable(61256, 18), false)
check("season-18 feat hidden at 17", isObtainable(62447, 17), false)
check("season-18 feat obtainable at 18", isObtainable(62447, 18), true)
check("seasonal feat hidden when season unknown", isObtainable(61256, nil), false)
check("unknown id not obtainable", isObtainable(99999999, 17), false)

print("")
if failures == 0 then
	print("ALL PASS")
	os.exit(0)
else
	print(failures .. " FAILURE(S)")
	os.exit(1)
end
