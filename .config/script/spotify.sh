#!/bin/bash

notify_spotify() {
    tmpimg=$(mktemp --suffix=.png)

    status=$(playerctl -p spotify status 2>/dev/null)
    if [[ "$status" != "Playing" ]]; then
      #  notify-send "Spotify" "Spotify is not playing"
        rm -f "$tmpimg"
        return
    fi

    title=$(playerctl -p spotify metadata title 2>/dev/null)
    artist=$(playerctl -p spotify metadata artist 2>/dev/null)
    arturl=$(playerctl -p spotify metadata mpris:artUrl 2>/dev/null)

    if [[ -z "$title" || -z "$artist" ]]; then
        notify-send "Spotify" "No song info available"
        rm -f "$tmpimg"
        return
    fi

    if [[ -n "$arturl" ]]; then
        if [[ "$arturl" == file://* ]]; then
            cp "${arturl#file://}" "$tmpimg"
        else
            curl -s "$arturl" -o "$tmpimg"
        fi
    fi

    if [[ -f "$tmpimg" ]]; then
        notify-send "Now Playing" "$title by $artist" -i "$tmpimg"
        rm -f "$tmpimg"
    else
        notify-send "Now Playing" "$title by $artist" -i spotify
    fi
}

# Only show notification when the song changes
playerctl -p spotify metadata --format '{{title}}' --follow | while read -r _; do
    notify_spotify
done
