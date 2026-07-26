#!/bin/sh
# Regenerates FactionData.lua from the current wago.tools Achievement.db2
# export. Run when a new patch adds faction-locked achievements.
set -e
cd "$(dirname "$0")"
./fetch-db2.sh
cd ..

CSV="tools/db2/Achievement.csv" python3 - <<'EOF'
import csv, os, datetime
rows = list(csv.DictReader(open(os.environ["CSV"])))
locked = sorted((int(r["ID"]), int(r["Faction"])) for r in rows if r["Faction"] != "-1")
today = datetime.date.today().isoformat()
out = open("FactionData.lua", "w")
out.write(f"""-- FactionData.lua: achievement IDs locked to one faction. The game API does
-- not expose an achievement's faction, so this is generated from the
-- Achievement.db2 export at https://wago.tools/db2/Achievement/csv
-- (Faction column: 0 = Horde, 1 = Alliance; -1 = both, omitted here).
-- Regenerate with tools/update-faction-data.sh after new patches.
-- Generated {today}. Do not edit by hand.
local ADDON_NAME, RA = ...;

RA.FACTION_HORDE = 0;
RA.FACTION_ALLIANCE = 1;

RA.factionLocked = {{
""")
line = []
for id_, fac in locked:
    line.append(f"[{id_}]={fac}")
    if len(line) == 10:
        out.write("\t" + ",".join(line) + ",\n"); line = []
if line:
    out.write("\t" + ",".join(line) + ",\n")
out.write("};\n")
out.close()
print(f"Wrote FactionData.lua ({len(locked)} faction-locked achievements)")
EOF
