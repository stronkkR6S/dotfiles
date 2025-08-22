#!/bin/bash

# Set the screenshot directory
dir="$HOME/ss"

# Create directory if it doesn't exist
mkdir -p "$dir"

# Find the first available filename that doesn't exist
i=0
while [[ -e "$dir/ssr-$i.png" ]]; do
    ((i++))
done

# Full filename path
filename="$dir/ssr-$i.png"
# Launch region select and take screenshot
grim -g "$(slurp)" "$filename"

paplay /usr/share/sounds/freedesktop/stereo/camera-shutter.oga &
# Send notification with screenshot as icon and path
notify-send -i "$filename" "📸 Region " "$filename"
