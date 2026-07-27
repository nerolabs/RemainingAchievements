-- UnobtainableData.lua: achievements that are no longer earnable yet survive
-- every automated data filter -- they sit in a visible category, carry no
-- distinguishing flag, and have no season or time-limit wording, so nothing in
-- the generated data can tell them apart from obtainable feats. Hand-curated
-- from in-game reports and patch history.
--
-- This is the explicit-removal tier of Feat-of-Strength obtainability; the
-- other tier is the FoSData.lua allowlist resolved live against the season (see
-- the obtainability note in Core.lua). Add an id here when a tester reports a
-- removed feat still showing; where known, the comment cites the patch it left
-- the game in.
local ADDON_NAME, RA = ...;

RA.unobtainable = {
	-- Non-FoS: Temple of Kotmogu scenario, removed during the MoP beta.
	[7268] = true, [7269] = true, [7270] = true,
	-- Visible-list one-time event: Scarab Lord (opening the AQ gates).
	[416] = true,
	-- Removed hidden Feats of Strength:
	[425] = true,                   -- Atiesh (original Naxxramas, removed in WotLK)
	[430] = true,                   -- Amani War Bear (removed with the Zul'Aman revamp)
	[880] = true, [881] = true,     -- Swift Zulian Tiger / Swift Razzashi Raptor (Cata Zul'Gurub revamp)
	[2496] = true,                  -- The Fifth Element (Aqual Quintessence quests, removed in Cata)
	[3896] = true,                  -- Onyx Panther
	[4079] = true, [4156] = true,   -- A Tribute to Immortality (Crusader's Black Warhorse)
	[5313] = true,                  -- I Can't Hear You Over the Sound of How Awesome I Am (Sinestra HC)
	[5788] = true,                  -- Agent of the Shen'dralar (reputation no longer gainable)
	[8812] = true,                  -- You're Really Doing It Wrong (Level 90); the current version (9597) is still obtainable
	[3004] = true, [3005] = true,   -- He Feeds On Your Tears (Algalon 10/25)
	[1436] = true, [4832] = true, [8213] = true, [8794] = true, [9925] = true, -- Brawler's Guild "Friends In..." chain
	[8089] = true,                  -- I Thought He Was Supposed to Be Hard? (removed patch 6.0.2)
	[11387] = true,                 -- The Chosen (Trial of Valor; removed patch 8.0.1)
	[13779] = true, [14140] = true, -- Phenomenal Cosmic Power / Mad World (removed patch 9.0.1)
	[40095] = true, [40096] = true, [41953] = true, [41971] = true, -- Sparking Battle / Mad World / Through the Looking Glass (removed patch 12.0.0)
	[42212] = true, [42241] = true, -- Titan Console Overcharged / Overcharged Delver (removed patch 11.2.0)
	[40446] = true,                 -- I TAKE Candle!
};
