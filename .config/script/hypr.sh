#!/bin/bash

# Get wallpaper path from pywal
image="$(cat "$HOME/.cache/wal/wal")"

# Absolute path to magick binary
MAGICK_BIN="/usr/bin/magick"

# Output path
output="$HOME/script/output.jpg"

# Generate square image using absolute magick path
"$MAGICK_BIN" "$image" -resize 1080x1080^ -gravity center -extent 1080x1080 "$output"
