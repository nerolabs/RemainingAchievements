#!/bin/sh
# Regenerates FoSData.lua: the obtainable hidden Feats of Strength.
# Every FoS achievement is hidden-until-earned, so the addon discovers them
# by ID and needs this list to separate obtainable feats from the expired
# seasonal debris that looks identical in the data.
#
# PER-SEASON CHORE: update CURRENT_MARKERS below when a new season starts
# (branding strings from the new season's feat titles), then rerun.
set -e
cd "$(dirname "$0")"
./fetch-db2.sh
cd ..

python3 - <<'EOF'
import csv, re, datetime

# Branding that identifies the CURRENT season's time-limited feats.
# Midnight Season 2 (updated 2026-07-26): season label, gladiator prefix,
# current raid end boss, current delve boss.
CURRENT_MARKERS = ["midnight season 2", "venomous", "ula'tek", "azta'rec",
                   "midnight: journey's end"]
GENERIC_SEASON2_ID_FLOOR = 62000  # "(Season 2)" alone is ambiguous vs TWW S2

RETIRED_CATS = {'15268', '15270', '15274'}  # Promotions, PvP, Events
BAD_FLAGS = 0x100 | 0x200 | 0x40000 | 0x100000 | 0x1000000 | 0x1
# Textual markers for retired content the flags miss: "realm first" (457 has
# only 0x800, no realm-first bits), "realm-best" (MoP/WoD Challenge Master,
# challenge modes removed at Legion prepatch), "region-best" (Keystone Victor
# — same one-slot competitive class as realm-first, and expired-season copies
# carry no season wording), "no longer attainable" (Old School Ride says it
# outright).
JUNK = re.compile(r"stress test|remix|awakened|deprecated|\[dnt\]|\(copy\)"
                  r"|realm first|realm-best|region-best|no longer attainable")
# NOT a plain "before": evergreen feats use it too ("before any player is
# hit", 4524; "the hallway before Scourgelord", 4525). AotC/Cutting Edge are
# time-limited by name — tier phrasing varies (opening/beginning of the next
# raid) — and only the current pair survives via CURRENT_MARKERS.
TIME_LIMITED = re.compile(r"season|before the release|before the opening"
                          r"|before the beginning|before the expedition"
                          r"|replaced by|during the"
                          r"|ahead of the curve|cutting edge")

ach = list(csv.DictReader(open('tools/db2/Achievement.csv')))
cats = {r['ID']: r for r in csv.DictReader(open('tools/db2/Achievement_Category.csv'))}
fos = {'81'}
changed = True
while changed:
    changed = False
    for cid, r in cats.items():
        if r['Parent'] in fos and cid not in fos:
            fos.add(cid); changed = True

keep = []
for r in ach:
    if r['Category'] not in fos or r['Category'] in RETIRED_CATS:
        continue
    if int(r['Flags']) & BAD_FLAGS:
        continue
    text = (r['Title_lang'] + ' ' + r['Description_lang']).lower()
    if JUNK.search(text):
        continue
    if TIME_LIMITED.search(text):
        if 'season 1' in text or 'season one' in text:
            continue
        current = any(m in text for m in CURRENT_MARKERS) or \
            ('(season 2)' in text and int(r['ID']) >= GENERIC_SEASON2_ID_FLOOR)
        if not current:
            continue
    keep.append(r)

keep.sort(key=lambda r: int(r['ID']))
today = datetime.date.today().isoformat()
out = open('FoSData.lua', 'w')
out.write(f"""-- FoSData.lua: obtainable hidden Feats of Strength. All FoS achievements
-- are hidden-until-earned and expired seasonal feats are byte-identical to
-- obtainable ones in the game data, so this list is generated from the
-- Achievement.db2 export (wago.tools): evergreen feats (no time-limit
-- wording) plus the current season's feats.
-- Regenerate with tools/update-fos-data.sh each season. Generated {today}.
-- Do not edit by hand.
local ADDON_NAME, RA = ...;

RA.obtainableHiddenFoS = {{
""")
for r in keep:
    out.write(f"\t[{r['ID']}] = true, -- {r['Title_lang']}\n")
out.write("};\n")
out.close()
print(f"Wrote FoSData.lua ({len(keep)} feats)")
EOF
