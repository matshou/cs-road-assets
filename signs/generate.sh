#!/bin/bash
if [ -z "$1" ]; then
	echo "Missing command argument PATH"
	return
else
	BASE_PATH="$1"
fi
if [ "$2" == "--thumbnails" ]; then
	EXPORT_DIR="$1"'/thumb/export'
	find "$EXPORT_DIR" -maxdepth 1 -iregex '.*\.\(png\)' -printf '%f\n' > data.tmp
	printf "Generating thumbnail files...\n"
	declare GENERATED
	while IFS="" read -r p || [ -n "$p" ]
	do
		pattern="^([^\_]+)\_([^.]+)(\.[a-zA-Z]+)"
		if [[ "$p" =~ $pattern ]]; then
			SRC_PATH="$EXPORT_DIR"'/'"$p"
			DIR_PATH="$EXPORT_DIR"'/'"${BASH_REMATCH[1]}"
			ASSET_NAME="${BASH_REMATCH[2]}"
			FILE_EXT="${BASH_REMATCH[3]}"
			DEST_PATH="$DIR_PATH"'/'"$ASSET_NAME""$FILE_EXT"
			TOOLTIP="$BASE_PATH"'/thumb/asset_tooltip.png'
			CP_PATH="$DIR_PATH"'/asset_tooltip.png'
			mkdir -p "$DIR_PATH" && cp "$TOOLTIP" "$CP_PATH"
			mv "$SRC_PATH" "$DEST_PATH"
			GENERATED=$((GENERATED+1))
		fi
	done < data.tmp
	rm -f data.tmp
	printf "Generated %d files\n" "$GENERATED"
elif [ "$2" == "--snapshots" ]; then
	EXPORT_DIR="$1"'/snapshot/export'
	find "$EXPORT_DIR" -maxdepth 1 -iregex '.*\.\(png\)' -printf '%f\n' > data.tmp
	printf "Generating snapshot files...\n"
	declare GENERATED
	while IFS="" read -r p || [ -n "$p" ]
	do
		pattern="^(.*)\.png+"
		if [[ "$p" =~ $pattern ]]; then
			ASSET_NAME="${BASH_REMATCH[1]}"
			SRC_DIR="$EXPORT_DIR"'/'"$p"
			DEST_DIR="$EXPORT_DIR"'/'"$ASSET_NAME"
			TARGET_PATH="$DEST_DIR"'/snapshot.png'
			mkdir -p "$DEST_DIR"
			mv "$SRC_DIR" "$TARGET_PATH"
			cp "$1"'/snapshot/tooltip.png' "$DEST_DIR"
			SRC_DIR="$1"'/thumb/export/'"$ASSET_NAME"'/asset_thumb.png'
			if [ -f "$SRC_DIR" ]; then
				cp "$SRC_DIR" "$DEST_DIR"'/thumbnail.png'
			else
				printf "Warning: Unable to find thumbnail for %s\n%s\n" "$p" "$SRC_DIR"
			fi
			GENERATED=$((GENERATED+1))
		fi
	done < data.tmp
	rm -f data.tmp
	printf "Generated %d files\n" "$GENERATED"
else
	printf "Unknown operation mode\n"
fi
