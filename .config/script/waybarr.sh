#!/bin/bash

WAYBAR_DIR="$HOME/.config/waybar"

STYLE1="style-main.css"
STYLE2="style-alt.css"
CONFIG1="config-main.jsonc"
CONFIG2="config-alt.jsonc"

STYLE_LINK="$WAYBAR_DIR/style.css"
CONFIG_LINK="$WAYBAR_DIR/config"

STYLE1_PATH="$WAYBAR_DIR/$STYLE1"
STYLE2_PATH="$WAYBAR_DIR/$STYLE2"
CONFIG1_PATH="$WAYBAR_DIR/$CONFIG1"
CONFIG2_PATH="$WAYBAR_DIR/$CONFIG2"

CURRENT_STYLE=$(readlink "$STYLE_LINK" || echo "")
CURRENT_CONFIG=$(readlink "$CONFIG_LINK" || echo "")

if [[ $CURRENT_STYLE == "$STYLE1_PATH" ]]; then
    ln -sf "$STYLE2_PATH" "$STYLE_LINK"
    ln -sf "$CONFIG2_PATH" "$CONFIG_LINK"
    notify-send "Waybar ALT"
else
    ln -sf "$STYLE1_PATH" "$STYLE_LINK"
    ln -sf "$CONFIG1_PATH" "$CONFIG_LINK"
    notify-send "Waybar MAIN"
fi

# Restart Waybar
pkill waybar && nohup waybar >/dev/null 2>&1 &
