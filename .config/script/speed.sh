#!/bin/bash

interface="wlp1s0"

# Check if interface exists
if ! ip link show "$interface" &>/dev/null; then
    notify-send "❌ Interface '$interface' not found"
    exit 1
fi

rx_prev=$(cat /sys/class/net/$interface/statistics/rx_bytes)
tx_prev=$(cat /sys/class/net/$interface/statistics/tx_bytes)
sleep 1

while true; do
    rx_now=$(cat /sys/class/net/$interface/statistics/rx_bytes)
    tx_now=$(cat /sys/class/net/$interface/statistics/tx_bytes)

    rx_rate=$(( (rx_now - rx_prev) / 1024 ))  # Download KB/s
    tx_rate=$(( (tx_now - tx_prev) / 1024 ))  # Upload KB/s

    notify-send "📡 Network Speed" "↓ ${rx_rate} KB/s   ↑ ${tx_rate} KB/s"

    rx_prev=$rx_now
    tx_prev=$tx_now

    sleep 5
done

