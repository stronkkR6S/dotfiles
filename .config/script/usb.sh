#!/bin/bash

# This version avoids duplicates by waiting for full blocks of device info
udevadm monitor --udev --subsystem-match=usb --property | {
    action=""
    vendor=""
    model=""

    while read -r line; do
        case "$line" in
            ACTION=add)
                action="🔌 USB Device Plugged In"
                ;;
            ACTION=remove)
                action="❌ USB Device Removed"
                ;;
            ID_VENDOR=*)
                vendor="${line#ID_VENDOR=}"
                ;;
            ID_MODEL=*)
                model="${line#ID_MODEL=}"
                ;;
            "")
                # Blank line marks the end of an event block
                if [[ -n "$action" ]]; then
                    notify-send "$action" "${vendor:-Unknown} ${model:-Device}"
                    action=""
                    vendor=""
                    model=""
                fi
                ;;
        esac
    done
}

