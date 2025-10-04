#!/bin/bash

updates_count=$(emerge --pretend --update --deep --with-bdeps=y @world | grep -c "^\[")

if [ "$updates_count" -gt 0 ]; then
    notify-send "📦 Gentoo Updates Available" "$updates_count packages need updating"
else
    notify-send "✅ Gentoo System" "No updates available"
fi

