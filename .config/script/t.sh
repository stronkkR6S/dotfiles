#!/bin/bash

BRIGHTNESS_ID_FILE="/tmp/brightness_notify_id"
SOUND_CHANGE="/usr/share/sounds/freedesktop/stereo/audio-volume-change.oga"

play_sound() {
    local file="$1"
    [[ -f $file ]] && paplay "$file" &
}

case "$1" in
up)
    brightnessctl set 5%+ && play_sound "$SOUND_CHANGE"
    ;;
down)
    brightnessctl set 5%- && play_sound "$SOUND_CHANGE"
    ;;
set)
    brightnessctl set "$2" && play_sound "$SOUND_CHANGE"
    ;;
*)
    exec brightnessctl "$@"
    ;;
esac

PERCENT=$(brightnessctl -d amdgpu_bl0 | grep -oP '\(\K[0-9]+(?=%\))' || echo 0)

ICON="display-brightness-high"
((PERCENT < 66)) && ICON="display-brightness-medium"
((PERCENT < 33)) && ICON="display-brightness-low"

PREV_ID=$(cat "$BRIGHTNESS_ID_FILE" 2>/dev/null || echo 0)
NEW_ID=$(notify-send -p -a "Brightness" -r "$PREV_ID" -h int:value:"$PERCENT" -i "$ICON" "Brightness" "Brightness: ${PERCENT}%")
echo "$NEW_ID" >"$BRIGHTNESS_ID_FILE"
