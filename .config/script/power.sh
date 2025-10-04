#!/bin/bash

current=$(powerprofilesctl get)

case "$current" in
  performance)
    powerprofilesctl set balanced
    new_profile="Balanced ⚖️"
    ;;
  balanced)
    powerprofilesctl set power-saver
    new_profile="Power Saver 🔋"
    ;;
  power-saver)
    powerprofilesctl set performance
    new_profile="Performance 🚀"
    ;;
  *)
    powerprofilesctl set balanced
    new_profile="Balanced ⚖️"
    ;;
esac

notify-send "Power Profile" "Switched to: $new_profile"

