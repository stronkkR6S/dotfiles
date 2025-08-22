#!/bin/bash

# Kill if running
pkill -x waybar
sleep 0.8
# Start
waybar &
sleep 2.5
# Re-apply layerrule
hyprctl -q --batch "keyword layerrule blur,waybar; keyword layerrule ignorezero,waybar"
