#!/bin/bash

while true; do
    if swaymsg -t get_tree | jq -r '.. | objects | select(.app_id? == "firefox-bin") | .name' | grep -iq "Instagram"; then
        notify-send "Instagram detected!" "Suspending your PC..."
        loginctl suspend
    fi
    sleep 2
done
