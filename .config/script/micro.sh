#!/bin/bash

VOLUME_ID_FILE="/tmp/mic_notify_id"
LAST_VOLUME=""
LAST_MUTED=""
LAST_ACTIVE_VOLUME=""
LAST_DEVICE=""
FIRST_RUN=true

# Sound files
SOUND_CHANGE="/usr/share/sounds/freedesktop/stereo/audio-volume-change.oga"
SOUND_MUTED="/usr/share/sounds/freedesktop/stereo/window-attention.oga"
SOUND_UNMUTED="$SOUND_CHANGE"

play_sound() {
    local file="$1"
    [[ -f $file ]] && paplay "$file" &
}

is_integer() {
    [[ $1 =~ ^[0-9]+$ ]]
}

get_default_source() {
    pactl info | grep "Default Source" | cut -d ":" -f2 | xargs
}

while true; do
    CURRENT_DEVICE=$(get_default_source)

    # Get capture volume
    AMIXER_LINE=$(amixer get Capture | grep -m 1 -E -o '[0-9]+%')
    VOLUME_INT=$(echo "$AMIXER_LINE" | grep -o '[0-9]\+')

    # Get mute state
    MUTE_LINE=$(amixer get Capture | grep -m 1 '\[on\]\|\[off\]')
    IS_MUTED=$(echo "$MUTE_LINE" | grep -q '\[off\]' && echo "yes" || echo "no")

    if [ -z "$VOLUME_INT" ] || ! is_integer "$VOLUME_INT" || [ -z "$CURRENT_DEVICE" ]; then
        sleep 0.5
        continue
    fi

    # If device changed or it's the very first loop, store state and skip notify
    if [ "$FIRST_RUN" = true ] || [ "$CURRENT_DEVICE" != "$LAST_DEVICE" ]; then
        LAST_DEVICE="$CURRENT_DEVICE"
        LAST_VOLUME="$VOLUME_INT"
        LAST_MUTED="$IS_MUTED"
        LAST_ACTIVE_VOLUME="$VOLUME_INT"
        FIRST_RUN=false
        sleep 0.5
        continue
    fi

    if [[ $VOLUME_INT == "$LAST_VOLUME" && $IS_MUTED == "$LAST_MUTED" ]]; then
        sleep 0.5
        continue
    fi

    UNMUTED_NOW=false
    MUTED_NOW=false
    VOLUME_CHANGED=false

    [[ $IS_MUTED == "no" && $LAST_MUTED == "yes" ]] && UNMUTED_NOW=true
    [[ $IS_MUTED == "yes" && $LAST_MUTED == "no" ]] && MUTED_NOW=true
    [[ $VOLUME_INT != "$LAST_VOLUME" ]] && VOLUME_CHANGED=true

    LAST_VOLUME="$VOLUME_INT"
    LAST_MUTED="$IS_MUTED"
    [[ $IS_MUTED == "no" ]] && LAST_ACTIVE_VOLUME="$VOLUME_INT"

    if [ "$IS_MUTED" == "yes" ]; then
        ICON="microphone-sensitivity-muted"
        TEXT="Microphone muted"
        play_sound "$SOUND_MUTED"
    elif [ "$UNMUTED_NOW" == "true" ]; then
        if [ "$LAST_ACTIVE_VOLUME" -lt 33 ]; then
            ICON="microphone-sensitivity-low"
        elif [ "$LAST_ACTIVE_VOLUME" -lt 66 ]; then
            ICON="microphone-sensitivity-medium"
        else
            ICON="microphone-sensitivity-high"
        fi
        TEXT="Microphone unmuted"
        play_sound "$SOUND_UNMUTED"
    else
        if [ "$VOLUME_INT" -lt 33 ]; then
            ICON="microphone-sensitivity-low"
        elif [ "$VOLUME_INT" -lt 66 ]; then
            ICON="microphone-sensitivity-medium"
        else
            ICON="microphone-sensitivity-high"
        fi
        TEXT="Mic volume: ${VOLUME_INT}%"
        play_sound "$SOUND_CHANGE"
    fi

    PREV_ID=$(cat "$VOLUME_ID_FILE" 2>/dev/null || echo 0)
    NEW_ID=$(notify-send -p -a "Microphone" -r "$PREV_ID" -h int:value:"$VOLUME_INT" -i "$ICON" "Microphone" "$TEXT")
    echo "$NEW_ID" >"$VOLUME_ID_FILE"

    sleep 0.5
done
