-- Throwaway diagnostic. Paste the whole thing after /run, OR load as a tiny
-- addon and type /raprobe. It only READS API state and prints lines to chat.
-- Copy everything between the >>>> and <<<< markers back to the dev.
local function p(k, v) print("RAPROBE|"..k.."="..tostring(v)) end

print(">>>> RAPROBE BEGIN")

-- Client / version
p("build", (select(4, GetBuildInfo())))     -- interface number, e.g. 120000
p("version", (GetBuildInfo()))              -- e.g. "12.0.0"

-- Mythic+ season (the linchpin for keystone feats)
if C_MythicPlus and C_MythicPlus.GetCurrentSeason then
    p("mplus_current", C_MythicPlus.GetCurrentSeason())
else
    p("mplus_current", "NO_API")
end
p("cvar_newMythicPlusSeason", GetCVar and GetCVar("newMythicPlusSeason"))

-- PvP / arena season (for a later gladiator pass — informational only)
p("arena_current", GetCurrentArenaSeason and GetCurrentArenaSeason())
p("arena_previous", GetPreviousArenaSeason and GetPreviousArenaSeason())

-- Spot-check specific achievements. For each: does the client know it,
-- is it completed, and (if exposed) its hidden flag.
-- IDs: current-guess Midnight S2 keystone master will be filled once known;
-- for now we probe a past-season one + an evergreen one to sanity-check.
local probeIDs = {
    19011,  -- Dragonflight Keystone Master: Season Three  (PAST - expect not-current)
    20525,  -- The War Within Keystone Explorer: Season One (PAST)
    426,    -- Warglaives of Azzinoth (evergreen FoS - expect always valid)
    20511,  -- Gotta Punt em' All (obtainable hidden secret - control)
}
for _, id in ipairs(probeIDs) do
    local valid = C_AchievementInfo and C_AchievementInfo.IsValidAchievement
        and C_AchievementInfo.IsValidAchievement(id)
    local ok, _, name, _, completed, _, _, _, flags = pcall(GetAchievementInfo, id)
    if ok then
        print(("RAPROBE|ach|%d|valid=%s|name=%s|completed=%s|flags=%s")
            :format(id, tostring(valid), tostring(name),
                    tostring(completed), tostring(flags)))
    else
        print(("RAPROBE|ach|%d|GetAchievementInfo_ERROR"):format(id))
    end
end

print("<<<< RAPROBE END")
