-- FoSData.lua: obtainable hidden Feats of Strength. All FoS achievements
-- are hidden-until-earned and expired seasonal feats are byte-identical to
-- obtainable ones in the game data, so this list is generated from the
-- Achievement.db2 export (wago.tools).
-- Entry values: `true` = evergreen (always obtainable); `{ season = N }` = a
-- seasonal feat (keystone, gladiator, delve, raid AotC/Cutting Edge, ...)
-- obtainable only while global season N is live (N is the DisplaySeason.db2
-- season number, matched against GetCurrentSeason() in Core.lua, so past
-- seasons self-expire and new ones appear with no regen).
-- Regenerate with tools/update-fos-data.sh. Generated 2026-07-27. Do not edit by hand.
local ADDON_NAME, RA = ...;

RA.obtainableHiddenFoS = {
	[424] = true, -- Why? Because It's Red
	[425] = true, -- Atiesh, Greatstaff of the Guardian
	[426] = true, -- Warglaives of Azzinoth
	[428] = true, -- Thunderfury, Blessed Blade of the Windseeker
	[429] = true, -- Sulfuras, Hand of Ragnaros
	[430] = true, -- Amani War Bear
	[725] = true, -- Thori'dal, the Stars' Fury
	[729] = true, -- Deathcharger's Reins
	[871] = true, -- Avast Ye, Admiral!
	[880] = true, -- Swift Zulian Tiger
	[881] = true, -- Swift Razzashi Raptor
	[882] = true, -- Fiery Warhorse's Reins
	[883] = true, -- Reins of the Raven Lord
	[884] = true, -- Swift White Hawkstrider
	[885] = true, -- Ashes of Al'ar
	[980] = true, -- The Horseman's Reins
	[1205] = true, -- Hero of Shattrath
	[1436] = true, -- Friends In High Places
	[2081] = true, -- Grand Black War Mammoth
	[2336] = true, -- Insane in the Membrane
	[2496] = true, -- The Fifth Element
	[3004] = true, -- He Feeds On Your Tears (10 player)
	[3005] = true, -- He Feeds On Your Tears (25 player)
	[3142] = true, -- Val'anyr, Hammer of Ancient Kings
	[3316] = true, -- Herald of the Titans
	[3356] = true, -- Winterspring Frostsaber
	[3357] = true, -- Venomhide Ravasaur
	[3496] = true, -- A Brew-FAST Mount
	[3896] = true, -- Onyx Panther
	[4079] = true, -- A Tribute to Immortality
	[4156] = true, -- A Tribute to Immortality
	[4496] = true, -- It's Over Nine Thousand!
	[4524] = true, -- Doesn't Go to Eleven
	[4525] = true, -- Don't Look Up
	[4623] = true, -- Shadowmourne
	[4625] = true, -- Invincible's Reins
	[4626] = true, -- And I'll Form the Head!
	[4627] = true, -- X-45 Heartbreaker
	[4832] = true, -- Friends In Even Higher Places
	[5313] = true, -- I Can't Hear You Over the Sound of How Awesome I Am
	[5767] = true, -- Scourer of the Eternal Sands
	[5788] = true, -- Agent of the Shen'dralar
	[5839] = true, -- Dragonwrath, Tarecgosa's Rest
	[6181] = true, -- Fangs of the Father
	[8089] = true, -- I Thought He Was Supposed to Be Hard?
	[8092] = true, -- I've Got 9999 Problems but a Bone-White Primal Raptor Ain't One
	[8213] = true, -- Friends In Places Higher Yet
	[8794] = true, -- Friends In Places Even Higher Than That
	[8812] = true, -- You're Really Doing It Wrong (Level 90)
	[9033] = true, -- Ready for Raiding IV
	[9034] = true, -- Magnify... Enhance
	[9036] = true, -- Monomania
	[9597] = true, -- You're Really Doing It Wrong
	[9925] = true, -- Friends In Places Yet Even Higher Than That
	[10334] = true, -- Predator
	[11137] = true, -- A Legendary Campaign
	[11387] = true, -- The Chosen
	[11744] = true, -- Drop Dead, Gorgeous
	[11869] = true, -- I'll Hold These For You Until You Get Out
	[12004] = true, -- Welcome the Void
	[12005] = true, -- Let it All Out
	[12009] = true, -- Darker Side
	[12503] = true, -- Snake Eyes
	[12508] = true, -- Good Night, Sweet Prince
	[13779] = true, -- Phenomenal Cosmic Power
	[13789] = true, -- Hertz Locker
	[14140] = true, -- Mad World
	[14183] = true, -- Conspicuous Consumption
	[14531] = { season = 5 }, -- Shadowlands Keystone Conqueror: Season One
	[14532] = { season = 5 }, -- Shadowlands Keystone Master: Season One
	[14685] = { season = 5 }, -- Combatant: Shadowlands Season 1
	[14686] = { season = 5 }, -- Challenger: Shadowlands Season 1
	[14687] = { season = 5 }, -- Rival: Shadowlands Season 1
	[14688] = { season = 5 }, -- Duelist: Shadowlands Season 1
	[14689] = { season = 5 }, -- Gladiator: Shadowlands Season 1
	[14690] = { season = 5 }, -- Sinful Gladiator: Shadowlands Season 1
	[14691] = { season = 5 }, -- Elite: Shadowlands Season 1
	[14692] = { season = 5 }, -- Hero of the Alliance: Sinful
	[14693] = { season = 5 }, -- Hero of the Horde: Sinful
	[14816] = { season = 5 }, -- Sinful Gladiator's Soul Eater
	[14938] = { season = 5 }, -- Shadowlands Keystone Explorer: Season One
	[14968] = { season = 6 }, -- Combatant I: Shadowlands Season 2
	[14969] = { season = 6 }, -- Challenger I: Shadowlands Season 2
	[14970] = { season = 6 }, -- Rival I: Shadowlands Season 2
	[14971] = { season = 6 }, -- Duelist: Shadowlands Season 2
	[14972] = { season = 6 }, -- Gladiator: Shadowlands Season 2
	[14973] = { season = 6 }, -- Unchained Gladiator: Shadowlands Season 2
	[14974] = { season = 6 }, -- Elite: Shadowlands Season 2
	[14975] = { season = 6 }, -- Hero of the Alliance: Unchained
	[14976] = { season = 6 }, -- Hero of the Horde: Unchained
	[14999] = { season = 6 }, -- Unchained Gladiator's Soul Eater
	[15073] = { season = 6 }, -- Shadowlands Keystone Explorer: Season Two
	[15077] = { season = 6 }, -- Shadowlands Keystone Conqueror: Season Two
	[15078] = { season = 6 }, -- Shadowlands Keystone Master: Season Two
	[15191] = true, -- Rae'shalare, Death's Whisper
	[15232] = { season = 6 }, -- Combatant II: Shadowlands Season 2
	[15233] = { season = 6 }, -- Challenger II: Shadowlands Season 2
	[15234] = { season = 6 }, -- Rival II: Shadowlands Season 2
	[15327] = { season = 6 }, -- Tormented Hero: Shadowlands Season 2
	[15348] = { season = 7 }, -- Combatant I: Shadowlands Season 3
	[15349] = { season = 7 }, -- Challenger I: Shadowlands Season 3
	[15350] = { season = 7 }, -- Rival I: Shadowlands Season 3
	[15351] = { season = 7 }, -- Duelist: Shadowlands Season 3
	[15352] = { season = 7 }, -- Gladiator: Shadowlands Season 3
	[15353] = { season = 7 }, -- Cosmic Gladiator: Shadowlands Season 3
	[15354] = { season = 7 }, -- Elite: Shadowlands Season 3
	[15355] = { season = 7 }, -- Hero of the Alliance: Cosmic
	[15356] = { season = 7 }, -- Hero of the Horde: Cosmic
	[15378] = { season = 7 }, -- Rival II: Shadowlands Season 3
	[15379] = { season = 7 }, -- Challenger II: Shadowlands Season 3
	[15380] = { season = 7 }, -- Combatant II: Shadowlands Season 3
	[15384] = { season = 7 }, -- Cosmic Gladiator's Soul Eater
	[15496] = { season = 7 }, -- Shadowlands Keystone Explorer: Season Three
	[15498] = { season = 7 }, -- Shadowlands Keystone Conqueror: Season Three
	[15499] = { season = 7 }, -- Shadowlands Keystone Master: Season Three
	[15506] = { season = 7 }, -- Shadowlands Keystone Hero: Season Three
	[15600] = { season = 8 }, -- Challenger I: Shadowlands Season 4
	[15601] = { season = 8 }, -- Challenger II: Shadowlands Season 4
	[15602] = { season = 8 }, -- Rival I: Shadowlands Season 4
	[15603] = { season = 8 }, -- Rival II: Shadowlands Season 4
	[15604] = { season = 8 }, -- Duelist: Shadowlands Season 4
	[15605] = { season = 8 }, -- Gladiator: Shadowlands Season 4
	[15606] = { season = 8 }, -- Eternal Gladiator: Shadowlands Season 4
	[15607] = { season = 8 }, -- Hero of the Horde: Eternal
	[15608] = { season = 8 }, -- Hero of the Alliance: Eternal
	[15609] = { season = 8 }, -- Combatant I: Shadowlands Season 4
	[15610] = { season = 8 }, -- Combatant II: Shadowlands Season 4
	[15612] = { season = 8 }, -- Eternal Gladiator's Soul Eater
	[15639] = { season = 8 }, -- Elite: Shadowlands Season 4
	[15684] = { season = 8 }, -- Fates of the Shadowlands Raids
	[15685] = { season = 8 }, -- Heroic: Fates of the Shadowlands Raids
	[15687] = { season = 8 }, -- Mythic: Fates of the Shadowlands Raids
	[15688] = { season = 8 }, -- Shadowlands Keystone Explorer: Season Four
	[15689] = { season = 8 }, -- Shadowlands Keystone Conqueror: Season Four
	[15690] = { season = 8 }, -- Shadowlands Keystone Master: Season Four
	[15691] = { season = 7 }, -- Cryptic Hero: Shadowlands Season 3
	[15756] = { season = 8 }, -- Shrouded Hero: Shadowlands Season 4
	[15951] = { season = 9 }, -- Crimson Gladiator: Dragonflight Season 1
	[15952] = { season = 9 }, -- Rival I: Dragonflight Season 1
	[15953] = { season = 9 }, -- Rival II: Dragonflight Season 1
	[15955] = { season = 9 }, -- Challenger I: Dragonflight Season 1
	[15956] = { season = 9 }, -- Challenger II: Dragonflight Season 1
	[15957] = { season = 9 }, -- Gladiator: Dragonflight Season 1
	[15958] = { season = 9 }, -- Hero of the Horde: Crimson
	[15959] = { season = 9 }, -- Hero of the Alliance: Crimson
	[15960] = { season = 9 }, -- Combatant I: Dragonflight Season 1
	[15961] = { season = 9 }, -- Combatant II: Dragonflight Season 1
	[16429] = { season = 9 }, -- Thundering Hero: Dragonflight Season 1
	[16647] = { season = 9 }, -- Dragonflight Keystone Explorer: Season One
	[16648] = { season = 9 }, -- Dragonflight Keystone Conqueror: Season One
	[16649] = { season = 9 }, -- Dragonflight Keystone Master: Season One
	[16650] = { season = 9 }, -- Dragonflight Keystone Hero: Season One
	[16730] = { season = 9 }, -- Crimson Gladiator's Drake
	[16734] = { season = 9 }, -- Crimson Legend: Dragonflight Season 1
	[17339] = { season = 9 }, -- Legend: Dragonflight Season 1
	[17740] = { season = 10 }, -- Gladiator: Dragonflight Season 2
	[17764] = { season = 10 }, -- Obsidian Gladiator: Dragonflight Season 2
	[17767] = { season = 10 }, -- Obsidian Legend: Dragonflight Season 2
	[17768] = { season = 10 }, -- Hero of the Alliance: Obsidian
	[17772] = { season = 10 }, -- Hero of the Horde: Obsidian
	[17778] = { season = 10 }, -- Obsidian Gladiator's Slitherdrake
	[17795] = { season = 10 }, -- Rival I: Dragonflight Season 2
	[17796] = { season = 10 }, -- Rival II: Dragonflight Season 2
	[17797] = { season = 10 }, -- Challenger I: Dragonflight Season 2
	[17798] = { season = 10 }, -- Challenger II: Dragonflight Season 2
	[17799] = { season = 10 }, -- Combatant I: Dragonflight Season 2
	[17800] = { season = 10 }, -- Combatant II: Dragonflight Season 2
	[17801] = { season = 10 }, -- Legend: Dragonflight Season 2
	[17842] = { season = 10 }, -- Dragonflight Keystone Explorer: Season Two
	[17843] = { season = 10 }, -- Dragonflight Keystone Conqueror: Season Two
	[17844] = { season = 10 }, -- Dragonflight Keystone Master: Season Two
	[17845] = { season = 10 }, -- Dragonflight Keystone Hero: Season Two
	[17846] = { season = 10 }, -- Smoldering Hero: Dragonflight Season 2
	[18027] = { season = 10 }, -- Dragonflight Season 2 Master
	[18256] = true, -- Nasz'uro, the Unbound Legacy
	[18380] = { season = 10 }, -- Dragonflight Season 2 Hero
	[19009] = { season = 11 }, -- Dragonflight Keystone Explorer: Season Three
	[19010] = { season = 11 }, -- Dragonflight Keystone Conqueror: Season Three
	[19011] = { season = 11 }, -- Dragonflight Keystone Master: Season Three
	[19012] = { season = 11 }, -- Dragonflight Keystone Hero: Season Three
	[19091] = { season = 11 }, -- Gladiator: Dragonflight Season 3
	[19131] = { season = 11 }, -- Verdant Legend: Dragonflight Season 3
	[19132] = { season = 11 }, -- Verdant Gladiator: Dragonflight Season 3
	[19133] = { season = 11 }, -- Rival I: Dragonflight Season 3
	[19155] = { season = 11 }, -- Rival II: Dragonflight Season 3
	[19157] = { season = 11 }, -- Combatant I: Dragonflight Season 3
	[19158] = { season = 11 }, -- Combatant II: Dragonflight Season 3
	[19159] = { season = 11 }, -- Challenger I: Dragonflight Season 3
	[19160] = { season = 11 }, -- Challenger II: Dragonflight Season 3
	[19161] = { season = 11 }, -- Hero of the Horde: Verdant
	[19162] = { season = 11 }, -- Hero of the Alliance: Verdant
	[19295] = { season = 11 }, -- Verdant Gladiator's Slitherdrake
	[19304] = { season = 11 }, -- Legend: Dragonflight Season 3
	[19326] = { season = 11 }, -- Dreaming of Drakes
	[19396] = { season = 11 }, -- Dragonflight Season 3 Master
	[19397] = { season = 11 }, -- Dreaming of Wyrms
	[19398] = { season = 11 }, -- Dreaming of the Aspects
	[19420] = { season = 11 }, -- Dragonflight Season 3 Hero
	[19443] = { season = 11 }, -- Battle Mender: Dragonflight Season 3
	[19449] = { season = 11 }, -- Dreaming Hero: Dragonflight Season 3
	[19450] = true, -- Fyr'alath the Dreamrender
	[19453] = { season = 12 }, -- Draconic Legend: Dragonflight Season 4
	[19454] = { season = 12 }, -- Draconic Gladiator: Dragonflight Season 4
	[19455] = { season = 12 }, -- Hero of the Alliance: Draconic
	[19456] = { season = 12 }, -- Hero of the Horde: Draconic
	[19489] = true, -- Class Connoisseur
	[19490] = { season = 12 }, -- Gladiator: Dragonflight Season 4
	[19493] = { season = 12 }, -- Rival I: Dragonflight Season 4
	[19494] = { season = 12 }, -- Combatant I: Dragonflight Season 4
	[19495] = { season = 12 }, -- Combatant II: Dragonflight Season 4
	[19497] = { season = 12 }, -- Challenger I: Dragonflight Season 4
	[19498] = { season = 12 }, -- Rival II: Dragonflight Season 4
	[19499] = { season = 12 }, -- Challenger II: Dragonflight Season 4
	[19500] = { season = 12 }, -- Legend: Dragonflight Season 4
	[19503] = { season = 12 }, -- Draconic Gladiator's Drake
	[19513] = { season = 12 }, -- Battle Mender: Dragonflight Season 4
	[19780] = { season = 12 }, -- Dragonflight Keystone Explorer: Season Four
	[19781] = { season = 12 }, -- Dragonflight Keystone Conqueror: Season Four
	[19782] = { season = 12 }, -- Dragonflight Keystone Master: Season Four
	[19783] = { season = 12 }, -- Dragonflight Keystone Hero: Season Four
	[19785] = { season = 12 }, -- Draconic Hero: Dragonflight Season 4
	[20481] = { season = 12 }, -- Dragonflight Season 4 Master
	[20523] = { season = 13 }, -- The War Within Keystone Explorer: Season One
	[20524] = { season = 13 }, -- The War Within Keystone Conqueror: Season One
	[20525] = { season = 13 }, -- The War Within Keystone Master: Season One
	[20526] = { season = 13 }, -- The War Within Keystone Hero: Season One
	[20589] = { season = 13 }, -- Tempered Hero: The War Within Season 1
	[40095] = true, -- Sparking Battle
	[40096] = true, -- Sparking Battle
	[40098] = true, -- Immortal Spelunker
	[40100] = true, -- Undying Caver
	[40107] = { season = 13 }, -- Harbinger of the Weathered
	[40115] = { season = 13 }, -- Harbinger of the Carved
	[40118] = { season = 13 }, -- Harbinger of the Runed
	[40233] = { season = 13 }, -- Strategist: The War Within Season 1
	[40234] = { season = 13 }, -- Forged Warlord: The War Within Season 1
	[40235] = { season = 13 }, -- Forged Marshal: The War Within Season 1
	[40380] = { season = 13 }, -- Forged Gladiator: The War Within Season 1
	[40381] = { season = 13 }, -- Forged Legend: The War Within Season 1
	[40383] = { season = 13 }, -- Hero of the Alliance: Forged
	[40384] = { season = 13 }, -- Hero of the Horde: Forged
	[40385] = { season = 13 }, -- Combatant I: The War Within Season 1
	[40386] = { season = 13 }, -- Combatant II: The War Within Season 1
	[40387] = { season = 13 }, -- Challenger I: The War Within Season 1
	[40388] = { season = 13 }, -- Challenger II: The War Within Season 1
	[40389] = { season = 13 }, -- Rival I: The War Within Season 1
	[40390] = { season = 13 }, -- Rival II: The War Within Season 1
	[40393] = { season = 13 }, -- Gladiator: The War Within Season 1
	[40395] = { season = 13 }, -- Legend: The War Within Season 1
	[40398] = { season = 13 }, -- Forged Gladiator's Fel Bat
	[40446] = true, -- I TAKE Candle!
	[40452] = true, -- Just Keep Swimming
	[40472] = { season = 13 }, -- Battle Mender: The War Within Season 1
	[40515] = { season = 13 }, -- War Within Delves: Tier 4 (Season 1)
	[40516] = { season = 13 }, -- War Within Delves: Tier 5 (Season 1)
	[40517] = { season = 13 }, -- War Within Delves: Tier 6 (Season 1)
	[40518] = { season = 13 }, -- War Within Delves: Tier 7 (Season 1)
	[40519] = { season = 13 }, -- War Within Delves: Tier 8 (Season 1)
	[40520] = { season = 13 }, -- War Within Delves: Tier 9 (Season 1)
	[40521] = { season = 13 }, -- War Within Delves: Tier 10 (Season 1)
	[40660] = { season = 13 }, -- The War Within Season 1: Spelunker Supreme
	[40726] = { season = 13 }, -- War Within Delves: Tier 11 (Season 1)
	[40911] = { season = 14 }, -- The War Within Season 2: Master Blaster
	[40939] = { season = 13 }, -- Harbinger of the Gilded
	[40942] = { season = 14 }, -- Weathered of the Undermine
	[40943] = { season = 14 }, -- Carved of the Undermine
	[40944] = { season = 14 }, -- Runed of the Undermine
	[40945] = { season = 14 }, -- Gilded of the Undermine
	[40949] = { season = 14 }, -- The War Within Keystone Explorer: Season Two
	[40950] = { season = 14 }, -- The War Within Keystone Conqueror: Season Two
	[40951] = { season = 14 }, -- The War Within Keystone Legend: Season Two
	[40952] = { season = 14 }, -- The War Within Keystone Hero: Season Two
	[40954] = { season = 14 }, -- Enterprising Hero: The War Within Season Two
	[40967] = true, -- Ratts' Revenge
	[41016] = { season = 14 }, -- Rival I: The War Within Season 2
	[41017] = { season = 14 }, -- Rival II: The War Within Season 2
	[41020] = { season = 14 }, -- Combatant I: The War Within Season 2
	[41021] = { season = 14 }, -- Combatant II: The War Within Season 2
	[41022] = { season = 14 }, -- Challenger I: The War Within Season 2
	[41023] = { season = 14 }, -- Challenger II: The War Within Season 2
	[41024] = { season = 15 }, -- Rival I: The War Within Season 3
	[41025] = { season = 15 }, -- Rival II: The War Within Season 3
	[41028] = { season = 15 }, -- Combatant I: The War Within Season 3
	[41029] = { season = 15 }, -- Combatant II: The War Within Season 3
	[41030] = { season = 15 }, -- Challenger I: The War Within Season 3
	[41031] = { season = 15 }, -- Challenger II: The War Within Season 3
	[41032] = { season = 14 }, -- Gladiator: The War Within Season 2
	[41044] = { season = 13 }, -- Forged Weapons of Conquest
	[41047] = { season = 14 }, -- Prized Weapons of Conquest
	[41048] = { season = 15 }, -- Astral Weapons of Conquest
	[41049] = { season = 15 }, -- Gladiator: The War Within Season 3
	[41191] = { season = 14 }, -- War Within Delves: Tier 4 (Season 2)
	[41192] = { season = 14 }, -- War Within Delves: Tier 5 (Season 2)
	[41193] = { season = 14 }, -- War Within Delves: Tier 7 (Season 2)
	[41194] = { season = 14 }, -- War Within Delves: Tier 8 (Season 2)
	[41195] = { season = 14 }, -- War Within Delves: Tier 9 (Season 2)
	[41196] = { season = 14 }, -- War Within Delves: Tier 10 (Season 2)
	[41197] = { season = 14 }, -- War Within Delves: Tier 11 (Season 2)
	[41198] = { season = 14 }, -- War Within Delves: Tier 6 (Season 2)
	[41354] = { season = 14 }, -- Prized Gladiator: The War Within Season 2
	[41355] = { season = 14 }, -- Prized Legend: The War Within Season 2
	[41356] = { season = 14 }, -- Prized Warlord: The War Within Season 2
	[41357] = { season = 14 }, -- Prized Marshal: The War Within Season 2
	[41358] = { season = 14 }, -- Legend: The War Within Season 2
	[41359] = { season = 14 }, -- Battle Mender: The War Within Season 2
	[41360] = { season = 14 }, -- Hero of the Horde: Prized
	[41361] = { season = 14 }, -- Hero of the Alliance: Prized
	[41362] = { season = 14 }, -- Prized Gladiator's Fel Bat
	[41363] = { season = 14 }, -- Strategist: The War Within Season 2
	[41531] = { season = 14 }, -- The Hataclysm
	[41533] = { season = 14 }, -- The War Within Keystone Master: Season Two
	[41630] = true, -- "Employee" of the Month
	[41709] = { season = 14 }, -- The War Within: Journey's End (Season 2)
	[41886] = { season = 15 }, -- Weathered of the Ethereal
	[41887] = { season = 15 }, -- Carved of the Ethereal
	[41888] = { season = 15 }, -- Runed of the Ethereal
	[41892] = { season = 15 }, -- Gilded of the Ethereal
	[41937] = { season = 15 }, -- The War Within Season 3: Voidborne Victor
	[41953] = true, -- Mad World
	[41971] = true, -- Through the Looking Glass
	[41973] = { season = 15 }, -- The War Within Keystone Master: Season Three
	[42023] = { season = 15 }, -- Legend: The War Within Season 3
	[42024] = { season = 15 }, -- Strategist: The War Within Season 3
	[42033] = { season = 15 }, -- Astral Legend: The War Within Season 3
	[42034] = { season = 15 }, -- Astral Warlord: The War Within Season 3
	[42035] = { season = 15 }, -- Astral Marshal: The War Within Season 3
	[42036] = { season = 15 }, -- Astral Gladiator: The War Within Season 3
	[42037] = { season = 15 }, -- Hero of the Horde: Astral
	[42038] = { season = 15 }, -- Hero of the Alliance: Astral
	[42039] = { season = 15 }, -- Astral Gladiator's Fel Bat
	[42044] = { season = 15 }, -- Battle Mender: The War Within Season 3
	[42139] = { season = 14 }, -- The Enterprising Tank
	[42141] = { season = 14 }, -- The Enterprising Healer
	[42144] = { season = 14 }, -- The Enterprising Damage Dealer
	[42148] = { season = 14 }, -- The Enterprising Dungeon Master
	[42149] = { season = 15 }, -- The War Within Season 3: Resilient Keystone 12
	[42150] = { season = 15 }, -- The War Within Season 3: Resilient Keystone 13
	[42151] = { season = 15 }, -- The War Within Season 3: Resilient Keystone 14
	[42152] = { season = 15 }, -- The War Within Season 3: Resilient Keystone 15
	[42153] = { season = 15 }, -- The War Within Season 3: Resilient Keystone 16
	[42154] = { season = 15 }, -- The War Within Season 3: Resilient Keystone 17
	[42155] = { season = 15 }, -- The War Within Season 3: Resilient Keystone 18
	[42156] = { season = 15 }, -- The War Within Season 3: Resilient Keystone 19
	[42157] = { season = 15 }, -- The War Within Season 3: Resilient Keystone 20
	[42158] = { season = 15 }, -- The War Within Season 3: Resilient Keystone 21
	[42159] = { season = 15 }, -- The War Within Season 3: Resilient Keystone 22
	[42160] = { season = 15 }, -- The War Within Season 3: Resilient Keystone 23
	[42161] = { season = 15 }, -- The War Within Season 3: Resilient Keystone 24
	[42162] = { season = 15 }, -- The War Within Season 3: Resilient Keystone 25
	[42169] = { season = 15 }, -- The War Within Keystone Explorer: Season Three
	[42170] = { season = 15 }, -- The War Within Keystone Conqueror: Season Three
	[42171] = { season = 15 }, -- The War Within Keystone Hero: Season Three
	[42172] = { season = 15 }, -- The War Within Keystone Legend: Season Three
	[42174] = { season = 15 }, -- Unbound Hero: The War Within Season Three
	[42196] = { season = 15 }, -- War Within Delves: Tier 4 (Season 3)
	[42197] = { season = 15 }, -- War Within Delves: Tier 5 (Season 3)
	[42198] = { season = 15 }, -- War Within Delves: Tier 6 (Season 3)
	[42199] = { season = 15 }, -- War Within Delves: Tier 7 (Season 3)
	[42200] = { season = 15 }, -- War Within Delves: Tier 8 (Season 3)
	[42201] = { season = 15 }, -- War Within Delves: Tier 9 (Season 3)
	[42202] = { season = 15 }, -- War Within Delves: Tier 10 (Season 3)
	[42203] = { season = 15 }, -- War Within Delves: Tier 11 (Season 3)
	[42212] = true, -- Titan Console Overcharged
	[42241] = true, -- Overcharged Delver
	[42767] = { season = 17 }, -- Veteran of the Dawn
	[42768] = { season = 17 }, -- Champion of the Dawn
	[42769] = { season = 17 }, -- Hero of the Dawn
	[42770] = { season = 17 }, -- Myth of the Dawn
	[42799] = true, -- Let Her Solo Me
	[42801] = { season = 15 }, -- The War Within: Journey's End (Season 3)
	[42802] = { season = 15 }, -- The War Within Season 3: Resilient Keystone 26
	[42803] = { season = 15 }, -- The War Within Season 3: Resilient Keystone 27
	[42804] = { season = 15 }, -- The War Within Season 3: Resilient Keystone 28
	[42805] = { season = 15 }, -- The War Within Season 3: Resilient Keystone 29
	[42806] = { season = 15 }, -- The War Within Season 3: Resilient Keystone 30
	[60933] = true, -- With Flying Colors
	[60934] = true, -- With Flying Colors
	[61092] = { season = 15 }, -- Hard Mode: Tazavesh, the Veiled Market
	[61093] = { season = 15 }, -- Flawless Transaction
	[61177] = { season = 17 }, -- Galactic Marshal: Midnight Season 1
	[61178] = { season = 17 }, -- Galactic Warlord: Midnight Season 1
	[61179] = { season = 17 }, -- Galactic Legend: Midnight Season 1
	[61180] = { season = 17 }, -- Galactic Gladiator: Midnight Season 1
	[61181] = { season = 17 }, -- Combatant I: Midnight Season 1
	[61182] = { season = 17 }, -- Combatant II: Midnight Season 1
	[61183] = { season = 17 }, -- Challenger I: Midnight Season 1
	[61184] = { season = 17 }, -- Challenger II: Midnight Season 1
	[61185] = { season = 17 }, -- Rival I: Midnight Season 1
	[61186] = { season = 17 }, -- Rival II: Midnight Season 1
	[61187] = { season = 17 }, -- Duelist: Midnight Season 1
	[61188] = { season = 17 }, -- Gladiator: Midnight Season 1
	[61190] = { season = 17 }, -- Legend: Midnight Season 1
	[61194] = { season = 17 }, -- Strategist: Midnight Season 1
	[61195] = { season = 17 }, -- Hero of the Alliance: Galactic
	[61196] = { season = 17 }, -- Hero of the Horde: Galactic
	[61197] = { season = 17 }, -- Elite: Midnight Season 1
	[61198] = { season = 17 }, -- Battle Mender: Midnight Season 1
	[61233] = { season = 17 }, -- Midnight Season 1: Resilient Keystone 12
	[61235] = { season = 17 }, -- Midnight Season 1: Resilient Keystone 13
	[61236] = { season = 17 }, -- Midnight Season 1: Resilient Keystone 14
	[61237] = { season = 17 }, -- Midnight Season 1: Resilient Keystone 15
	[61239] = { season = 17 }, -- Midnight Season 1: Resilient Keystone 16
	[61240] = { season = 17 }, -- Midnight Season 1: Resilient Keystone 17
	[61241] = { season = 17 }, -- Midnight Season 1: Resilient Keystone 18
	[61242] = { season = 17 }, -- Midnight Season 1: Resilient Keystone 19
	[61243] = { season = 17 }, -- Midnight Season 1: Resilient Keystone 20
	[61244] = { season = 17 }, -- Midnight Season 1: Resilient Keystone 21
	[61245] = { season = 17 }, -- Midnight Season 1: Resilient Keystone 22
	[61246] = { season = 17 }, -- Midnight Season 1: Resilient Keystone 23
	[61247] = { season = 17 }, -- Midnight Season 1: Resilient Keystone 24
	[61248] = { season = 17 }, -- Midnight Season 1: Resilient Keystone 25
	[61249] = { season = 17 }, -- Midnight Season 1: Resilient Keystone 26
	[61250] = { season = 17 }, -- Midnight Season 1: Resilient Keystone 27
	[61251] = { season = 17 }, -- Midnight Season 1: Resilient Keystone 28
	[61252] = { season = 17 }, -- Midnight Season 1: Resilient Keystone 29
	[61253] = { season = 17 }, -- Midnight Season 1: Resilient Keystone 30
	[61254] = { season = 17 }, -- Midnight Keystone Explorer: Season 1
	[61255] = { season = 17 }, -- Midnight Keystone Conqueror: Season 1
	[61256] = { season = 17 }, -- Midnight Keystone Master: Season 1
	[61257] = { season = 17 }, -- Midnight Keystone Hero: Season 1
	[61258] = { season = 17 }, -- Midnight Keystone Legend: Season 1
	[61259] = { season = 17 }, -- Umbral Hero: Midnight Season 1
	[61443] = { season = 17 }, -- Galactic Weapons of Conquest
	[61450] = { season = 17 }, -- Galactic Gladiator's Goredrake
	[61490] = { season = 17 }, -- Midnight Season 1: Champion of the Dawn
	[61491] = { season = 17 }, -- Ahead of the Curve: Chimaerus, the Undreamt God
	[61492] = { season = 17 }, -- Cutting Edge: Chimaerus, the Undreamt God
	[61516] = true, -- Radiant Singer
	[61519] = { season = 17 }, -- Midnight Season 1: Catalyst Unbound
	[61624] = { season = 17 }, -- Ahead of the Curve: Crown of the Cosmos
	[61625] = { season = 17 }, -- Cutting Edge: Crown of the Cosmos
	[61626] = { season = 17 }, -- Ahead of the Curve: Midnight Falls
	[61627] = { season = 17 }, -- Cutting Edge: Midnight Falls
	[61706] = true, -- Herald of the Goddess
	[61796] = { season = 17 }, -- Midnight: Journey's End (Season 1)
	[61800] = { season = 17 }, -- Midnight Delves: Tier 4 (Season 1)
	[61801] = { season = 17 }, -- Midnight Delves: Tier 5 (Season 1)
	[61802] = { season = 17 }, -- Midnight Delves: Tier 6 (Season 1)
	[61803] = { season = 17 }, -- Midnight Delves: Tier 7 (Season 1)
	[61804] = { season = 17 }, -- Midnight Delves: Tier 8 (Season 1)
	[61805] = { season = 17 }, -- Midnight Delves: Tier 9 (Season 1)
	[61806] = { season = 17 }, -- Midnight Delves: Tier 10 (Season 1)
	[61807] = { season = 17 }, -- Midnight Delves: Tier 11 (Season 1)
	[61809] = { season = 17 }, -- Adventurer of the Dawn
	[61874] = { season = 15 }, -- The Unbound Tank
	[61875] = { season = 15 }, -- The Unbound Healer
	[61876] = { season = 15 }, -- The Unbound Damage Dealer
	[61877] = { season = 15 }, -- The Unbound Dungeon Master
	[61917] = true, -- "Hold aggro, I got this"
	[62189] = true, -- Mind-Seeker
	[62388] = true, -- Illicit Rain: Five Stars
	[62410] = { season = 18 }, -- Adventurer of the Mist
	[62411] = { season = 18 }, -- Veteran of the Mist
	[62412] = { season = 18 }, -- Champion of the Mist
	[62414] = { season = 18 }, -- Hero of the Mist
	[62416] = { season = 18 }, -- Myth of the Mist
	[62417] = { season = 18 }, -- Midnight Season 2: Resilient Keystone 12
	[62418] = { season = 18 }, -- Midnight Season 2: Resilient Keystone 13
	[62419] = { season = 18 }, -- Midnight Season 2: Resilient Keystone 14
	[62420] = { season = 18 }, -- Midnight Season 2: Resilient Keystone 15
	[62421] = { season = 18 }, -- Midnight Season 2: Resilient Keystone 16
	[62422] = { season = 18 }, -- Midnight Season 2: Resilient Keystone 17
	[62423] = { season = 18 }, -- Midnight Season 2: Resilient Keystone 18
	[62424] = { season = 18 }, -- Midnight Season 2: Resilient Keystone 19
	[62425] = { season = 18 }, -- Midnight Season 2: Resilient Keystone 20
	[62426] = { season = 18 }, -- Midnight Season 2: Resilient Keystone 21
	[62427] = { season = 18 }, -- Midnight Season 2: Resilient Keystone 22
	[62428] = { season = 18 }, -- Midnight Season 2: Resilient Keystone 23
	[62429] = { season = 18 }, -- Midnight Season 2: Resilient Keystone 24
	[62430] = { season = 18 }, -- Midnight Season 2: Resilient Keystone 25
	[62431] = { season = 18 }, -- Midnight Season 2: Resilient Keystone 26
	[62432] = { season = 18 }, -- Midnight Season 2: Resilient Keystone 27
	[62433] = { season = 18 }, -- Midnight Season 2: Resilient Keystone 28
	[62434] = { season = 18 }, -- Midnight Season 2: Resilient Keystone 29
	[62435] = { season = 18 }, -- Midnight Season 2: Resilient Keystone 30
	[62436] = { season = 18 }, -- Venomous Hero: Midnight Season 2
	[62445] = { season = 18 }, -- Midnight Keystone Explorer: Season 2
	[62446] = { season = 18 }, -- Midnight Keystone Conqueror: Season 2
	[62447] = { season = 18 }, -- Midnight Keystone Master: Season 2
	[62448] = { season = 18 }, -- Midnight Keystone Hero: Season 2
	[62449] = { season = 18 }, -- Midnight Keystone Legend: Season 2
	[62497] = { season = 18 }, -- Venomous Weapons of Conquest
	[62871] = { season = 18 }, -- Midnight Season 2: Catalyst Unbound
	[62872] = { season = 18 }, -- Midnight Season 2: Serpent Scion
	[62889] = { season = 18 }, -- Midnight Delves: Tier 4 (Season 2)
	[62890] = { season = 18 }, -- Midnight Delves: Tier 5 (Season 2)
	[62891] = { season = 18 }, -- Midnight Delves: Tier 6 (Season 2)
	[62892] = { season = 18 }, -- Midnight Delves: Tier 7 (Season 2)
	[62893] = { season = 18 }, -- Midnight Delves: Tier 8 (Season 2)
	[62894] = { season = 18 }, -- Midnight Delves: Tier 9 (Season 2)
	[62895] = { season = 18 }, -- Midnight Delves: Tier 10 (Season 2)
	[62897] = { season = 18 }, -- Midnight Delves: Tier 11 (Season 2)
	[62911] = { season = 18 }, -- Rival II: Midnight Season 2
	[62921] = { season = 18 }, -- Battle Mender: Midnight Season 2
	[62922] = { season = 18 }, -- Venomous Gladiator: Midnight Season 2
	[62923] = { season = 18 }, -- Venomous Legend: Midnight Season 2
	[62924] = { season = 18 }, -- Venomous Marshal: Midnight Season 2
	[62925] = { season = 18 }, -- Venomous Warlord: Midnight Season 2
	[62926] = { season = 18 }, -- Combatant I: Midnight Season 2
	[62927] = { season = 18 }, -- Challenger I: Midnight Season 2
	[62928] = { season = 18 }, -- Rival I: Midnight Season 2
	[62929] = { season = 18 }, -- Duelist: Midnight Season 2
	[62930] = { season = 18 }, -- Gladiator: Midnight Season 2
	[62931] = { season = 18 }, -- Elite: Midnight Season 2
	[62932] = { season = 18 }, -- Legend: Midnight Season 2
	[62950] = { season = 18 }, -- Strategist: Midnight Season 2
	[62951] = { season = 18 }, -- Combatant II: Midnight Season 2
	[62952] = { season = 18 }, -- Challenger II: Midnight Season 2
	[62953] = { season = 18 }, -- Hero of the Alliance: Venomous
	[62954] = { season = 18 }, -- Hero of the Horde: Venomous
	[62955] = { season = 18 }, -- Venomous Gladiator's Goredrake
	[63097] = { season = 17 }, -- Midnight Keystone Myth: Season 1
	[63104] = { season = 17 }, -- Umbral Champion: Midnight Season 1
	[63164] = { season = 17 }, -- Big Prey Hunter (Season 1)
	[63326] = { season = 18 }, -- My Venomous Nemesis
	[63332] = { season = 18 }, -- Purging the Poison
	[63333] = { season = 18 }, -- Let Me Solo Him: Azta'rec
	[63334] = { season = 18 }, -- Fabled Let Me Solo Him: Azta'rec
	[63433] = { season = 18 }, -- Midnight: Journey's End (Season 2)
	[63611] = { season = 18 }, -- Big Prey Hunter (Season 2)
	[63650] = { season = 18 }, -- Ahead of the Curve: Ula'tek
	[63651] = { season = 18 }, -- Cutting Edge: Ula'tek
};
