#!/bin/bash

# Extend PATH (if needed)
export PATH=$PATH:/home/ravish/.cargo/bin:/usr/local/bin:/usr/bin

# Default wallpaper directory
DEFAULT_DIR="/home/ravish/pictures/lol/fav/"

# Use provided argument or default
INPUT="${1:-$DEFAULT_DIR}"

# Determine image path based on input
if [ -d "$INPUT" ]; then
    # Pick a random image from directory
    BG=$(find "$INPUT" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.gif" \) | shuf -n 1)
elif [ -f "$INPUT" ]; then
    # Use the file directly
    BG="$INPUT"
else
    notify-send "Error" "File or directory does not exist: $INPUT"
    echo "Error: File or directory does not exist: $INPUT"
    exit 1
fi

# If no image is found or selected
if [ -z "$BG" ]; then
    notify-send "Theme Update Cancelled" "No image selected or found."
    echo "No valid image selected."
    exit 1
fi

# Set wallpaper using swww
/usr/bin/swww img "$BG" --transition-type center --transition-step 15 --transition-fps 60 &

# Generate theme with matugen (runs silently in background)
nohup /home/ravish/.cargo/bin/matugen image "$BG" >/dev/null 2>&1 &

# Apply pywal theme without setting wallpaper again
/usr/bin/wal -n -i "$BG" &&

    # Run walogram (apply theme to Telegram or others)
    /usr/local/bin/walogram &&

    # Notify success
    /usr/bin/notify-send -i "$BG" "Theme Updated"
