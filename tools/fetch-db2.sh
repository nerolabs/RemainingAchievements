#!/bin/sh
# Downloads fresh Achievement/Achievement_Category db2 exports from
# wago.tools into tools/db2/ (gitignored). All achievement-data analysis
# (faction tables, flag research, noise triage) must use these files, and
# they must be less than a week old — rerun this before that kind of work.
set -e
cd "$(dirname "$0")"
mkdir -p db2
curl -sfL "https://wago.tools/db2/Achievement/csv" -o db2/Achievement.csv
curl -sfL "https://wago.tools/db2/Achievement_Category/csv" -o db2/Achievement_Category.csv
# DisplaySeason maps (expansion, ordinal) -> the global M+ season number the
# FoS generator tags seasonal feats with (must match C_MythicPlus season live).
curl -sfL "https://wago.tools/db2/DisplaySeason/csv" -o db2/DisplaySeason.csv
echo "Fetched $(wc -l < db2/Achievement.csv | tr -d ' ') achievement rows, $(wc -l < db2/Achievement_Category.csv | tr -d ' ') category rows, $(wc -l < db2/DisplaySeason.csv | tr -d ' ') display-season rows."
