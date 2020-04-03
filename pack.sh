#!/bin/bash
target="public"
if [ $# -eq 0 ]; then
	printf "No project path supplied\n"
fi
mkdir -p "$target"
echo "Copying xcf project files..."
find "$1" -name '*.xcf' -exec cp --parents {} $target \;
echo "Copying blend project files..."
find "$1" -name '*.blend' -exec cp --parents {} $target \;
