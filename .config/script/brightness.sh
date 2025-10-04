#!/bin/bash

BRIGHTNESS_ID_FILE="/tmp/brightness_notify_id"

case "$1" in
up)
    brightnessctl set 5%+
    ;;
down)
    brightnessctl set 5%-
    ;;
set)
    brightnessctl set "$2"
    ;;
*)
    exec brightnessctl "$@"
    ;;
esac

# Get brightness percent
PERCENT=$(brightnessctl -d amdgpu_bl0 | grep -oP '\(\K[0-9]+(?=%\))' || echo 0)

# Choose icon
ICON="display-brightness-high"
((PERCENT < 66)) && ICON="display-brightness-medium"
((PERCENT < 33)) && ICON="display-brightness-low"

# Show notification
PREV_ID=$(cat "$BRIGHTNESS_ID_FILE" 2>/dev/null || echo 0)
NEW_ID=$(notify-send -p -a "Brightness" -r "$PREV_ID" -h int:value:"$PERCENT" -i "$ICON" "Brightness" "Brightness: ${PERCENT}%")
echo "$NEW_ID" >"$BRIGHTNESS_ID_FILE"
