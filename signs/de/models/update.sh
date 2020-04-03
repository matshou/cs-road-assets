#!/bin/bash
APP_DATA_PATH=$(echo $LOCALAPPDATA | sed 's/\\/\//g')
GAME_LOCAL_PATH="$APP_DATA_PATH/Colossal Order/Cities_Skylines"
IMPORT_PATH="$GAME_LOCAL_PATH/Addons/Import"
ASSET_LIST_PATH="../asset_list.txt"
EXPORT_PATH="export"
OUTPUT_PATH="output"
GENERATE=true
IMPORT=true
CLEAN=false
for i in "$@"
do
	if [[ "$i" == "--skip-import" ]]; then
		IMPORT=false
	elif [ "$i" == "--skip-generate" ]; then
		GENERATE=false
	elif [ "$i" == "--clean" ]; then
		CLEAN=true
	fi
done
# Clean output directory
if [ "$CLEAN" = true ]; then
	if [ -d "$OUTPUT_PATH" ]; then
		if [ ! -z "$(ls -A $OUTPUT_PATH)" ]; then
			echo "Cleaning generated model objects..."
			rm "$OUTPUT_PATH"/*
		fi
	else
		printf "ERROR: Unable to find directory %s\n" "$OUTPUT_PATH"
	fi
else
	# Generate import-ready objects
	if [ "$GENERATE" = true ]; then
		declare SRC_PATH GEN_COUNT GEN_MAX
		SIGN_PANELS=('warning' 'yield' 'priority' 'info_1' 'info_2' 'info_3' 'regulatory' 'stop' 'warning-crossing')
		MAX_PANELS=$(find define -maxdepth 1 -type f | wc -l)
		declare p0 p1 p2 p3 p4 p5 p6 p7 p8
		for (( i=0; i < $MAX_PANELS; i++ ))
		do
			IFS=$'\n' read -d '' -r -a 'p'"$i" < 'define/p'"$i"'.txt'
		done
		echo "Generating model objects..."
		while IFS="" read -r p || [ -n "$p" ]
		do
			for (( ia=0; ia < $MAX_PANELS; ia++ ))
			do
				key="p${ia}"
				eval 'entries=${#'${key}'[@]}'
				for (( ii=0; ii<$entries; ii++ ));
				do
					eval 'entry=${'${key}'['$ii']}'
					if [ "$entry" == "$p" ]; then
						eval 'panel=${SIGN_PANELS['$ia']}'
						SRC_PATH="$EXPORT_PATH"'/de_'"$panel"'_road_sign'
						break
					fi
				done
				if [ ! -z "$SRC_PATH" ]; then
					break;
				fi
			done
			if [ -z "$SRC_PATH" ]; then
				printf "Unable to find define for %s\n" "$p"
				GEN_MAX=$((GEN_MAX+2))
				continue
			fi
			DEST_PATH="$OUTPUT_PATH/"'de_road_sign_'"$p"
			# Make sure the target dir and source file exist
			mkdir -p "$OUTPUT_PATH"
			if test -f "$SRC_PATH.obj"; then
				M_DEST_PATH="$DEST_PATH"'.obj'
				 cp "$SRC_PATH.obj" "$M_DEST_PATH"
				 if test -f "$M_DEST_PATH"; then
					GEN_COUNT=$((GEN_COUNT+1))
				else
					printf "Failed to generate %s\n" "$M_DEST_PATH"
				fi
			else
				printf "Skipping %s\n" "$SRC_PATH"
			fi
			SRC_PATH="$SRC_PATH"'_LOD.obj'
			if test -f "$SRC_PATH"; then
				L_DEST_PATH="$DEST_PATH"'_LOD.obj'
				cp "$SRC_PATH" "$L_DEST_PATH"
				if test -f "$L_DEST_PATH"; then
					GEN_COUNT=$((GEN_COUNT+1))
				else
					printf "Failed to generate %s\n" "$L_DEST_PATH"
				fi
			else
				printf "Skipping %s\n" "$SRC_PATH"
			fi
			GEN_MAX=$((GEN_MAX+2))
			SRC_PATH=""
		done < "$ASSET_LIST_PATH"
		printf "Finished generating %d/%d object files\n" "$GEN_COUNT" "$GEN_MAX"
	fi
	# Copy generated files to imports
	if [ "$IMPORT" = true ]; then
		printf "\nCopying object files to imports...\n"
		find "$OUTPUT_PATH" -name '*.obj' -exec cp {} "$IMPORT_PATH" \;
		echo "Finished copying files!"
	fi
fi
