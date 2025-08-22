#!/bin/bash

# Kill Waybar if it's running
waybar_pid=$(pgrep -x waybar)

if [ -n "$waybar_pid" ]; then
    kill "$waybar_pid"
    echo "Waybar stopped."
fi

# Restart Waybar
waybar -c /home/ravish/.config/waybar/c -s /home/ravish/.config/waybar/s &
echo "Waybar restarted."
