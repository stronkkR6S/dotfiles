#!/bin/bash

last_state=""

while true; do
    ssid=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)

    if [[ -n "$ssid" && "$last_state" != "$ssid" ]]; then
        notify-send "📡 Connected" "Now connected to: $ssid"
        last_state="$ssid"
    elif [[ -z "$ssid" && -n "$last_state" ]]; then
        notify-send "❌ Disconnected" "Wi-Fi disconnected."
        last_state=""
    fi

    sleep 5
done

