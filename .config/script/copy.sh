#!/bin/bash

last_clip=""

while true; do
    current_clip=$(cliphist list | head -n 1)

    if [[ "$current_clip" != "$last_clip" && -n "$current_clip" ]]; then
        # Send with action to copy again
        notify-send \
            --action="copy-again=📋 Copy Again" \
            "Copied to Clipboard" "$current_clip"

        last_clip="$current_clip"
    fi

    sleep 1
done

