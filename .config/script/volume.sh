#!/bin/bash

VOLUME_ID_FILE="/tmp/volume_notify_id"
LAST_VOLUME=""
LAST_MUTED=""
LAST_ACTIVE_VOLUME=""
LAST_DEVICE=""
FIRST_RUN=true

SOUND_CHANGE="/usr/share/sounds/freedesktop/stereo/audio-volume-change.oga"
SOUND_MUTED="/usr/share/sounds/freedesktop/stereo/dialog-warning.oga"
SOUND_UNMUTED="/usr/share/sounds/freedesktop/stereo/window-question.oga"

play_sound() {
    [[ -f $1 ]] && paplay "$1" &
}

get_default_sink() {
    pactl info | grep "Default Sink" | cut -d ':' -f2 | xargs
}

while true; do
    CURRENT_DEVICE=$(get_default_sink)
    [[ -z $CURRENT_DEVICE ]] && sleep 0.2 && continue

    VOLUME_LINE=$(pactl get-sink-volume "$CURRENT_DEVICE")
    MUTE_LINE=$(pactl get-sink-mute "$CURRENT_DEVICE")

    VOLUME_INT=$(grep -oP '\d+(?=%)' <<<"$VOLUME_LINE" | head -1)
    IS_MUTED=$(grep -q "yes" <<<"$MUTE_LINE" && echo "yes" || echo "no")

    [[ -z $VOLUME_INT || -z $IS_MUTED ]] && sleep 0.1 && continue

    if $FIRST_RUN || [[ $CURRENT_DEVICE != "$LAST_DEVICE" ]]; then
        LAST_DEVICE="$CURRENT_DEVICE"
        LAST_VOLUME="$VOLUME_INT"
        LAST_MUTED="$IS_MUTED"
        LAST_ACTIVE_VOLUME="$VOLUME_INT"
        FIRST_RUN=false
        sleep 0.1
        continue
    fi

    if [[ $VOLUME_INT == "$LAST_VOLUME" && $IS_MUTED == "$LAST_MUTED" ]]; then
        sleep 0.1
        continue
    fi

    UNMUTED_NOW=false
    [[ $IS_MUTED == "no" && $LAST_MUTED == "yes" ]] && UNMUTED_NOW=true

    LAST_VOLUME="$VOLUME_INT"
    LAST_MUTED="$IS_MUTED"
    [[ $IS_MUTED == "no" ]] && LAST_ACTIVE_VOLUME="$VOLUME_INT"

    if [[ $IS_MUTED == "yes" ]]; then
        ICON="audio-volume-muted"
        TEXT="Muted"
        play_sound "$SOUND_MUTED"
    elif $UNMUTED_NOW; then
        ICON="audio-volume-high"
        ((LAST_ACTIVE_VOLUME < 66)) && ICON="audio-volume-medium"
        ((LAST_ACTIVE_VOLUME < 33)) && ICON="audio-volume-low"
        TEXT="Unmuted"
        play_sound "$SOUND_UNMUTED"
    else
        ICON="audio-volume-high"
        ((VOLUME_INT < 66)) && ICON="audio-volume-medium"
        ((VOLUME_INT < 33)) && ICON="audio-volume-low"
        TEXT="Volume: ${VOLUME_INT}%"
        play_sound "$SOUND_CHANGE"
    fi

    PREV_ID=$(cat "$VOLUME_ID_FILE" 2>/dev/null || echo 0)
    NEW_ID=$(notify-send -p -a "Volume" -r "$PREV_ID" -h int:value:"$VOLUME_INT" -i "$ICON" "Volume" "$TEXT")
    echo "$NEW_ID" >"$VOLUME_ID_FILE"

    sleep 0.1
done
