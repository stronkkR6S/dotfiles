#!/bin/bash

# Show options with Rofi

choice=$(echo -e "ChatGPT\nPro" | rofi -dmenu -p "Choose AI:")

# Act on choice

case "$choice" in

"ChatGPT") firefox-bin https://chatgpt.com & ;;

"Pro") firefox-bin https://www.perplexity.ai/ & ;;

*) exit 1 ;; # Exit if Esc is pressed or invalid input

esac
