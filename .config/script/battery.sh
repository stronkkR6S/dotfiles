#!/bin/bash

# Battery notification script for battery BAT1
BAT_PATH="/sys/class/power_supply/BAT1"

# Sound files
SOUND_LOW="/usr/share/sounds/freedesktop/stereo/dialog-warning.oga"
SOUND_CHARGING="/usr/share/sounds/freedesktop/stereo/power-plug.oga"
SOUND_FULL="/usr/share/sounds/freedesktop/stereo/complete.oga"
SOUND_DISCONNECT="/usr/share/sounds/freedesktop/stereo/power-unplug.oga"

# Read initial state silently
last_status=$(cat "$BAT_PATH/status" 2>/dev/null | tr '[:upper:]' '[:lower:]' | xargs)

# Sound play helper
play_sound() {
    [[ -f $1 ]] && paplay "$1" &
}

while true; do
    status=$(cat "$BAT_PATH/status" 2>/dev/null | tr '[:upper:]' '[:lower:]' | xargs)
    level=$(cat "$BAT_PATH/capacity" 2>/dev/null)

    if [ -z "$status" ] || [ -z "$level" ]; then
        sleep 30
        continue
    fi

    # Charging started
    if [ "$status" = "charging" ] && [ "$last_status" != "charging" ]; then
        notify-send "⚡ Charging" "Battery is charging."
        play_sound "$SOUND_CHARGING"
        last_status="charging"
        sleep 5
        continue
    fi

    # Fully charged
    if [ "$level" -ge 100 ] && [ "$status" = "full" ] && [ "$last_status" != "full" ]; then
        notify-send "✅ Battery Full" "Battery is fully charged."
        play_sound "$SOUND_FULL"
        last_status="full"
        sleep 60
        continue
    fi

    # Low battery warning — only if discharging
    if [ "$status" = "discharging" ] && [ "$level" -le 15 ] && [ "$last_status" != "low" ]; then
        notify-send "🔋 Low Battery" "Battery level is at ${level}%!"
        play_sound "$SOUND_LOW"
        last_status="low"
        sleep 60
        continue
    fi

    # Power disconnected — discharging above low threshold
    if [ "$status" = "discharging" ] && [ "$level" -gt 15 ] && [ "$last_status" != "discharging" ]; then
        notify-send "🔌 Power Disconnected" "Running on battery."
        play_sound "$SOUND_DISCONNECT"
        last_status="discharging"
        sleep 30
        continue
    fi

    # Reset only if nothing special is happening
    if [[ $status != "$last_status" ]] && [[ $status != "charging" && $status != "discharging" && $status != "full" ]]; then
        last_status=""
    fi

    sleep 15
done
