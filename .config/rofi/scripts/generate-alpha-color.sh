#!/usr/bin/env bash

colors_file="$HOME/.config/rofi/colors.rasi"
temp_file="$(mktemp)"

# Function to convert hex to rgba
hex_to_rgba() {
    hex=$1
    alpha=$2
    r=$((16#${hex:0:2}))
    g=$((16#${hex:2:2}))
    b=$((16#${hex:4:2}))
    echo "rgba($r,$g,$b, $alpha)"
}

# Extract hex values
primaryy_rgb=$(grep -Po 'primaryy\s*:\s*rgb\(\K[0-9,\s]+' "$colors_file" | head -n1)
secondary_hex=$(grep -Po 'secondary\s*:\s*#\K[0-9a-fA-F]{6}' "$colors_file" | head -n1)
tertiary_hex=$(grep -Po 'tertiary\s*:\s*#\K[0-9a-fA-F]{6}' "$colors_file" | head -n1)

# Prepare alpha values
if [[ -n $primaryy_rgb ]]; then
    primaryy_alpha_40="rgba(${primaryy_rgb// /}, 0.4)"
    primaryy_alpha_60="rgba(${primaryy_rgb// /}, 0.6)"
fi

[[ -n $secondary_hex ]] && secondary_alpha=$(hex_to_rgba "$secondary_hex" 0.7)
[[ -n $tertiary_hex ]] && tertiary_alpha=$(hex_to_rgba "$tertiary_hex" 0.5)

# Remove any existing alpha lines
sed -E '/^\s*(primaryy-alpha(-strong)?|secondary-alpha|tertiary-alpha):/d' "$colors_file" >"$temp_file"

# Insert alpha lines after matching base colors
awk -v a1="    primaryy-alpha: $primaryy_alpha_40;" \
    -v a2="    primaryy-alpha-strong: $primaryy_alpha_60;" \
    -v a3="    secondary-alpha: $secondary_alpha;" \
    -v a4="    tertiary-alpha: $tertiary_alpha;" '
    /^\s*primaryy:/ {
        print $0
        if (length(a1) > 0) print a1
        if (length(a2) > 0) print a2
        next
    }
    /^\s*secondary:/ {
        print $0
        if (length(a3) > 0) print a3
        next
    }
    /^\s*tertiary:/ {
        print $0
        if (length(a4) > 0) print a4
        next
    }
    { print }
' "$temp_file" >"$colors_file"

rm -f "$temp_file"

echo "✅ Alpha colors updated in $colors_file"
