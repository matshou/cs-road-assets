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
		INFO_SIGNS=('B6b1' 'B52' 'B53' 'B54' 'B55')
		WARNING_SIGNS=('AB1' 'AB2' 'AB25')
		echo "Generating model objects..."
		while IFS="" read -r p || [ -n "$p" ]
		do
			SET_PATH=false
			for i0 in "${INFO_SIGNS[@]}"
			do
				if [ "$i0" == "$p" ]; then
					SRC_PATH="$EXPORT_PATH/fra_information_road_sign"
				fi
			done
			for i1 in "${WARNING_SIGNS[@]}"
			do
				if [ "$i1" == "$p" ]; then
					SRC_PATH="$EXPORT_PATH/fra_warning_road_sign"
				fi
			done
			if [ -z "$SRC_PATH" ]; then
				if [ "$p" == "AB3b" ]; then
					SRC_PATH="$EXPORT_PATH/fra_give_way_road_sign"
				elif [ "$p" == "AB4" ]; then
					SRC_PATH="$EXPORT_PATH/fra_stop_road_sign"
				elif [ "${p:0:2}" == "AB" ]; then
					SRC_PATH="$EXPORT_PATH/fra_priority_road_sign"
				elif [ "${p:0:1}" == "A" ]; then
					SRC_PATH="$EXPORT_PATH/fra_warning_road_sign"
				elif [ "${p:0:1}" == "B" ]; then
					SRC_PATH="$EXPORT_PATH/fra_regulatory_road_sign"
				elif [ "${p:0:1}" == "C" ]; then
					SRC_PATH="$EXPORT_PATH/fra_information_road_sign"
				fi
			fi
			DEST_PATH="$OUTPUT_PATH/fra_road_sign_$p"
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
