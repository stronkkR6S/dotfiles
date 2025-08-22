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

    if [[ "$art_url" =~ ^file:// ]]; then
        art_path="${art_url#file://}"
    elif [[ -n "$art_url" ]]; then
        art_path="/tmp/album_art.jpg"
        curl -sL "$art_url" -o "$art_path"
    else
        art_path=""
    fi

    # Resize album art to 300x150 (horizontal banner)
    if [ -n "$art_path" ] && [ -f "$art_path" ]; then
        magick "$art_path" -resize 300x150^ -gravity center -extent 300x150 "$art_path"
    fi

    if [ -n "$title" ] && [ "$title" != "$current" ]; then
        current="$title"
        if [ -n "$art_path" ] && [ -f "$art_path" ]; then
            notify-send -a "Now Playing" -i "$art_path" "🎵 Now Playing" "$title - $artist"
        else
            notify-send -a "Now Playing" "🎵 Now Playing" "$title - $artist"
        fi
    fi

    sleep 2
done
