#!/bin/bash

get_chromium_player() {
    playerctl -l 2>/dev/null | grep chromium.instance | head -n 1
}

current=""
while true; do
    PLAYER=$(get_chromium_player)
    if [ -z "$PLAYER" ]; then
        sleep 2
        continue
    fi

    title=$(playerctl -p "$PLAYER" metadata title 2>/dev/null)
    artist=$(playerctl -p "$PLAYER" metadata artist 2>/dev/null)
    art_url=$(playerctl -p "$PLAYER" metadata mpris:artUrl 2>/dev/null)

    # Handle album art
    art_path=""
    if [[ $art_url =~ ^file:// ]]; then
        src_path="${art_url#file://}"
        if [ -f "$src_path" ]; then
            cp "$src_path" /tmp/album_art.jpg
            art_path="/tmp/album_art.jpg"
        fi
    elif [[ -n $art_url ]]; then
        curl -sL "$art_url" -o /tmp/album_art.jpg
        art_path="/tmp/album_art.jpg"
    fi

    # Only notify when song changes
    if [ -n "$title" ] && [ "$title" != "$current" ]; then
        current="$title"

        if [ -n "$art_path" ] && [ -f "$art_path" ]; then
            # Resize and pad album art
            magick "$art_path" -resize 100x100^ -gravity center -background "#000000" -extent 100x100 /tmp/album_art_resized.png

            # Send notification with image icon
            notify-send -a "                     Now Playing" \
                --icon=/tmp/album_art_resized.png \
                --hint=int:transient:1 \
                "        Now Playing" "$title - $artist"

        else
            # Fallback: no album art
            notify-send -a "Now Playing" --hint=int:transient:1 " Now Playing" "$title - $artist"
        fi
    fi

    sleep 2
done
