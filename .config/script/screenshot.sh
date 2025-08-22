#!/bin/bash

# 1. Set the screenshot save directory
dir="$HOME/ss"

# 2. Create the directory if it doesn't exist
mkdir -p "$dir"

# 3. Find the first available filename: ssr-0.png, ssr-1.png, etc.
i=0
while [[ -e "$dir/ssr-$i.png" ]]; do
    ((i++)) # Increment until a file does NOT exist
done

# 4. Build the full path
filename="$dir/ssr-$i.png"

# 5. Take screenshot using grim
grim "$filename"
paplay /usr/share/sounds/freedesktop/stereo/camera-shutter.oga &
# 6. Send notification with the image as icon
notify-send -i "$filename" "📸 Screenshot ssr-$i.png"
