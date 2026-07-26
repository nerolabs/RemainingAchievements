#!/bin/sh
# Copies the addon into the local WoW install for in-game testing before a
# release is tagged. Run it, then /reload in-game.
#
# Override the target with WOW_ADDON_DIR if the install ever moves.
set -e

DEST="${WOW_ADDON_DIR:-/Applications/World of Warcraft/_retail_/Interface/AddOns/RemainingAchievements}"

mkdir -p "$DEST"
rsync -v --delete --recursive \
	--include="*.lua" \
	--include="*.toc" \
	--exclude="*" \
	./ "$DEST/"

echo "Deployed $(grep '## Version' RemainingAchievements.toc) to $DEST"
echo "Type /reload in-game to pick it up."
