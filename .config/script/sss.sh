#!/bin/bash

# Create directory if it doesn't exist
mkdir -p /home/ravish/ss /home/ravish/ss/thumbs

# Count existing screenshots
count=$(ls /home/ravish/ss/ssr-*.png 2>/dev/null | wc -l)

# Define filenames
filename="/home/ravish/ss/ssr-$count.png"
thumb="/home/ravish/ss/thumbs/ssr-thumb-$count.png"

# Take the screenshot
grim "$filename"

# Create a square thumbnail (center crop + resize)
magick "$filename" -resize 256x256^ -gravity center -extent 256x256 "$thumb"

# Send a notification using the thumbnail as icon
notify-send -i "$thumb" "📸 Screenshot saved" "$filename"

