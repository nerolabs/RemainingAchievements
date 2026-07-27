#!/bin/sh
# Regenerates FoSData.lua: the obtainable hidden Feats of Strength.
# Every FoS achievement is hidden-until-earned, so the addon discovers them
# by ID and needs this list to separate obtainable feats from the expired
# seasonal debris that looks identical in the data.
#
# Seasonal feats whose title names an expansion + "Season N" (keystone,
# gladiator, delve, umbral, Dawn, ...) are tagged with their global season
# number from DisplaySeason.db2 and resolved against the live season in-game, so
# they self-expire with NO per-season edit here. Feats whose season can't be
# derived from the title (raid AotC/Cutting Edge -- "before the next raid tier",
# no season in the title) are dropped rather than guessed; that class is the
# known gap, tracked for a future runtime resolver.
set -e
cd "$(dirname "$0")"
./fetch-db2.sh
cd ..

python3 - <<'EOF'
import csv, re, datetime

RETIRED_CATS = {'15268', '15274'}  # Promotions, Events

# Raid Ahead-of-the-Curve / Cutting Edge feats are time-limited ("before the
# next raid tier") but carry NO season in their title or description -- only an
# Instance_ID. db2 has no instance->season link (all Midnight raids share the
# "Midnight Raid" category), so this is the one hand-kept mapping: raid
# Instance_ID -> the global M+ season it belongs to. Raid tiers launch with the
# M+ season, so the runtime resolver then self-expires each AotC/CE correctly.
# ADD a raid's Instance_ID here when a new tier ships (find it in Achievement.csv
# on the "Ahead of the Curve: <end boss>" row).
RAID_TIER_SEASON = {
    '2912': 17, '2913': 17, '2939': 17,  # Voidspire / Quel'Danas / Dreamrift (Midnight S1)
    '3004': 18,                            # Ula'tek (Midnight S2, not yet live)
}
BAD_FLAGS = 0x100 | 0x200 | 0x40000 | 0x100000 | 0x1000000 | 0x1
# Textual markers for retired content the flags miss: "realm first" (457 has
# only 0x800, no realm-first bits), "realm-best" (MoP/WoD Challenge Master,
# challenge modes removed at Legion prepatch), "region-best" (Keystone Victor
# — same one-slot competitive class as realm-first, and expired-season copies
# carry no season wording), "no longer attainable" (Old School Ride says it
# outright).
JUNK = re.compile(r"stress test|remix|awakened|deprecated|\[dnt\]|\(copy\)"
                  r"|realm first|realm-best|region-best|no longer attainable")
# Marks a feat as time-limited so, if its season couldn't be derived from the
# title, it is dropped rather than kept as evergreen. NOT a plain "before":
# evergreen feats use it too ("before any player is hit", 4524; "the hallway
# before Scourgelord", 4525). AotC/Cutting Edge phrasing varies (opening /
# beginning of the next raid tier).
TIME_LIMITED = re.compile(r"season|before the release|before the opening"
                          r"|before the beginning|before the expedition"
                          r"|replaced by|during the|fated raid"
                          r"|ahead of the curve|cutting edge")

# DisplaySeason.db2: (ExpansionID, per-expansion ordinal) -> global M+ season
# number. That global number is exactly what C_MythicPlus.GetCurrentSeason()
# returns in-game, so tagging a keystone feat with it lets the addon resolve
# obtainability against the live season instead of fragile branding text.
disp_season = {}
for r in csv.DictReader(open('tools/db2/DisplaySeason.csv')):
    try:
        exp = int(r['ExpansionID'])
        ordn = int(r['Field_9_2_0_41827_001'])
        season = int(r['Season'])
    except (ValueError, KeyError):
        continue
    if exp and ordn:
        disp_season[(exp, ordn)] = season

# Expansion display name -> ExpansionID. Only Shadowlands onward have
# DisplaySeason rows; earlier keystone seasons (BfA and before) have no row and
# fall through as permanently expired. Add a line when a new expansion ships.
EXPANSIONS = {"shadowlands": 8, "dragonflight": 9, "the war within": 10,
              "midnight": 11}
ORDINAL_WORDS = {"one": 1, "two": 2, "three": 3, "four": 4, "five": 5, "six": 6}
SEASON_ORDINAL = re.compile(r"season (\w+)", re.I)

def derive_season(title, desc):
    """Global M+ season number for any seasonal feat that names both an
    expansion (Shadowlands onward) and a season ordinal -- keystone, gladiator,
    delve, resilient keystone, umbral, Dawn-catalyst, etc.: 'Galactic Gladiator:
    Midnight Season 1', 'Midnight Delves: Tier 11 (Season 1)', 'The War Within
    Keystone Master: Season One'. Some feats carry the season only in the
    description ('Adventurer of the Dawn' -> "...during Midnight Season 1."), so
    the title is tried first, then the description. Ordinal is a word (older) or
    a digit (Midnight+). Returns None when no mappable expansion+season is found
    (evergreen feats, or content predating the DisplaySeason table)."""
    for text in (title.lower(), desc.lower()):
        exp = None
        for name, eid in EXPANSIONS.items():
            if name in text:
                exp = eid
                break
        if not exp:
            continue
        m = SEASON_ORDINAL.search(text)
        if not m:
            continue
        word = m.group(1)
        ordn = ORDINAL_WORDS.get(word) or (int(word) if word.isdigit() else None)
        if ordn:
            season = disp_season.get((exp, ordn))
            if season is not None:
                return season
    return None

ach = list(csv.DictReader(open('tools/db2/Achievement.csv')))
cats = {r['ID']: r for r in csv.DictReader(open('tools/db2/Achievement_Category.csv'))}
fos = {'81'}
changed = True
while changed:
    changed = False
    for cid, r in cats.items():
        if r['Parent'] in fos and cid not in fos:
            fos.add(cid); changed = True

# PvP FoS subtree (cat 15270). PvP feats are inherently seasonal/competitive, so
# any without a derivable season is an expired one-time title (old gladiator
# ranks, retired rating titles); those are dropped rather than kept as evergreen.
pvp = {'15270'}
changed = True
while changed:
    changed = False
    for cid, r in cats.items():
        if r['Parent'] in pvp and cid not in pvp:
            pvp.add(cid); changed = True

# Each kept entry is (row, value): value True = evergreen (always obtainable),
# or an int = the global M+ season the seasonal feat belongs to (resolved live).
keep = []
for r in ach:
    if r['Category'] not in fos or r['Category'] in RETIRED_CATS:
        continue
    if int(r['Flags']) & BAD_FLAGS:
        continue
    title = r['Title_lang']
    text = (title + ' ' + r['Description_lang']).lower()
    if JUNK.search(text):
        continue
    # Seasonal-branded feats (keystone, gladiator, delve, umbral, Dawn, ...)
    # carry their season number and self-expire at runtime.
    season = derive_season(title, r['Description_lang'])
    # Raid AotC/Cutting Edge carry no season text; tag them by raid Instance_ID.
    if season is None and TIME_LIMITED.search(text):
        season = RAID_TIER_SEASON.get(r['Instance_ID'])
    if season is not None:
        keep.append((r, season))
        continue
    # PvP feats with no derivable season are expired one-time titles -> drop.
    if r['Category'] in pvp:
        continue
    # Time-limited but with no derivable season (raid AotC/Cutting Edge with no
    # season in the text, or content predating DisplaySeason like BfA seasons):
    # can't be resolved at runtime, so drop rather than guess.
    if TIME_LIMITED.search(text):
        continue
    keep.append((r, True))

keep.sort(key=lambda kv: int(kv[0]['ID']))
seasonal = sum(1 for _, v in keep if v is not True)
today = datetime.date.today().isoformat()
out = open('FoSData.lua', 'w')
out.write(f"""-- FoSData.lua: obtainable hidden Feats of Strength. All FoS achievements
-- are hidden-until-earned and expired seasonal feats are byte-identical to
-- obtainable ones in the game data, so this list is generated from the
-- Achievement.db2 export (wago.tools).
-- Entry values: `true` = evergreen (always obtainable); `{{ season = N }}` = a
-- seasonal feat (keystone, gladiator, delve, raid AotC/Cutting Edge, ...)
-- obtainable only while global season N is live (N is the DisplaySeason.db2
-- season number, matched against GetCurrentSeason() in Core.lua, so past
-- seasons self-expire and new ones appear with no regen).
-- Regenerate with tools/update-fos-data.sh. Generated {today}. Do not edit by hand.
local ADDON_NAME, RA = ...;

RA.obtainableHiddenFoS = {{
""")
for r, value in keep:
    if value is True:
        out.write(f"\t[{r['ID']}] = true, -- {r['Title_lang']}\n")
    else:
        out.write(f"\t[{r['ID']}] = {{ season = {value} }}, -- {r['Title_lang']}\n")
out.write("};\n")
out.close()
print(f"Wrote FoSData.lua ({len(keep)} feats, {seasonal} seasonal)")
EOF
