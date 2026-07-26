#!/bin/sh
# Copies the addon into the local WoW install for in-game testing before a
# release is tagged, and cuts a tester zip (gitignored) in this directory
# with the same top-level RemainingAchievements/ layout the release
# packager produces. Run it, then /reload in-game.
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

VERSION="$(sed -n 's/^## Version: //p' RemainingAchievements.toc | tr -d '[:space:]')"
ZIP="$PWD/RemainingAchievements-$VERSION-dev-$(date +%Y%m%d-%H%M).zip"
STAGE="$(mktemp -d)"
mkdir "$STAGE/RemainingAchievements"
cp ./*.lua ./*.toc "$STAGE/RemainingAchievements/"
rm -f "$ZIP"
(cd "$STAGE" && zip -qr "$ZIP" RemainingAchievements)
rm -rf "$STAGE"

echo "Deployed $(grep '## Version' RemainingAchievements.toc) to $DEST"
echo "Tester zip: $ZIP"
echo "Type /reload in-game to pick it up."
