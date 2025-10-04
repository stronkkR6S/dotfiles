#!/bin/bash

DIR="$HOME/vid"
mkdir -p "$DIR"
FILENAME="$DIR/recording_$(date +'%Y-%m-%d_%H-%M-%S').mp4"
PIDFILE="/tmp/wf-recorder.pid"

# Toggle recording
if [[ -f $PIDFILE ]]; then
    PID=$(cat "$PIDFILE")
    if kill -0 "$PID" 2>/dev/null; then
        kill "$PID"
        notify-send "✅ Screen Recording" "Recording stopped and saved to:\n$FILENAME" -t 3000
    else
        notify-send "⚠️ Screen Recorder" "Recording process not found. Cleaning up."
    fi
    rm -f "$PIDFILE"
else
    notify-send "🎥 Screen Recording" "Recording started..." -t 2000

    nice -n -5 wf-recorder \
        -f "$FILENAME" \
        -c libx264 \
        -r 60 \
        --audio \
        --geometry 0,0 1920x1080 \
        --codec-args preset=veryslow,crf=14 &

    echo $! >"$PIDFILE"
fi
