#!/bin/bash

# Add common binary paths
export PATH="$PATH:/home/ravish/.cargo/bin:/usr/local/bin:/usr/bin"

# Directory containing wallpapers
WALLPAPER_DIR="$HOME/pictures/lol/fav"

# Use sxiv to select an image (X11 only, may not work under Wayland/Hyprland)
SELECTED=$(sxiv -bto "$WALLPAPER_DIR" | head -n 1)

# If an image was selected
if [ -n "$SELECTED" ]; then
    # Set wallpaper using swww with transition
    swww img "$SELECTED" --transition-type center --transition-step 15 --transition-fps 60 &

    # Generate terminal and GTK theme colors with matugen (run in background, no output)
    matugen image "$SELECTED" >/dev/null 2>&1 &

    # Apply pywal theme
    wal -n -i "$SELECTED" -o /home/ravish/script/hypr.sh &&
        walogram -B
    # Notify user of successful theme update
    notify-send -i "$SELECTED" "Theme Updated"

else
    # Notify user of cancellation
    notify-send "Theme Update Cancelled" "No image selected."
fi
