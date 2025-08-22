#!/usr/bin/env bash

STATUS_FILE="$XDG_RUNTIME_DIR/keyboard.status"

set_keyboard() {
    local state="$1"
    echo "$state" >"$STATUS_FILE"
    notify-send "   Keyboard ${state^^}"
    hyprctl keyword '$keyboard' "$state"
    hyprctl keyword device:a ''
}

if [[ ! -f $STATUS_FILE ]]; then
    set_keyboard false
elif grep -q "true" "$STATUS_FILE"; then
    set_keyboard false
else
    set_keyboard true
fi
