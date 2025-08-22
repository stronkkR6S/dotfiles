#!/bin/bash

# Search all files under $HOME (recursive)
file=$(find "$HOME" -type f 2>/dev/null |
    rofi -dmenu -l 15 -p "Upload to 0x0.st")

# Exit if user cancels
[[ -z $file ]] && exit

# Check if file still exists
if [[ ! -f $file ]]; then
    notify-send "Upload failed" "File not found: $file"
    exit 1
fi

# Upload file to 0x0.st
url=$(curl -s -F "file=@$file" https://0x0.st)

# Copy URL to clipboard and show notification
echo "$url" | wl-copy
notify-send "Upload Successful" "$url"
