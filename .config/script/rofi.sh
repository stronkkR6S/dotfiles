#!/bin/bash
rofi -show drun -run-command 'bash -c "paplay /usr/share/sounds/freedesktop/stereo/dialog-information.oga; exec \"$@\"" _ {cmd}'
