#!/bin/bash
APP_DATA_PATH=$(echo $LOCALAPPDATA | sed 's/\\/\//g')
GAME_LOCAL_PATH="$APP_DATA_PATH/Colossal Order/Cities_Skylines"
ASSETS_PATH="$GAME_LOCAL_PATH/Addons/Assets"
declare DEST_PATH
if [ -z "$1" ]; then
	echo "Missing command argument PATH"
	return
else
	ASSET_LIST_PATH="$1"'/asset_list.txt'
fi
printf "Verifying game assets found in:\n%s\n" "$ASSETS_PATH"
printf "Using list \"%s\"\n\n" "$ASSET_LIST_PATH"
declare MISSING_ASSETS VERIFIED_ASSETS
while IFS="" read -r p || [ -n "$p" ]
do
	FILE_NAME="$1"'_road_sign_'"$p"
	if [[ $FILE_NAME =~ "." ]]; then
		FILE_NAME="${FILE_NAME//\./%002E}"
	fi
	FILE_NAME="$FILE_NAME"'.crp'
	if [ ! -f "$ASSETS_PATH/$FILE_NAME" ]; then
		printf "Missing asset %s\n" "$FILE_NAME"
		MISSING_ASSETS=$((MISSING_ASSETS+1))
	else
		VERIFIED_ASSETS=$((VERIFIED_ASSETS+1))
	fi
done < "$ASSET_LIST_PATH"
if [[ $MISSING_ASSETS -ne 0 ]]; then
	printf "\n"
fi
printf "Finished verifying game assets\n"
printf "%d CRP assets found, %d missing\n" "$VERIFIED_ASSETS" "$MISSING_ASSETS"
