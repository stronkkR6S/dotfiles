#!/bin/bash

# WallSelect for Hyprland + Rofi Thumbnail Picker
# Author: Ravish (modified to use matugen, pywal, and walogram)

wall_dir="$HOME/pics/lol/fav"
cacheDir="$HOME/.cache/wallthumbs"
rofi_theme="$HOME/.config/rofi/wallselect.rasi"

# Fallback values
monitor_width=1920
screen_dpi=96
icon_size=$(((monitor_width * 20) / (${screen_dpi:-96})))
rofi_override="element-icon{size:${icon_size}px;}"
rofi_command="rofi -dmenu -theme $rofi_theme -theme-str $rofi_override"

mkdir -p "$cacheDir"

# Optimal parallel jobs
get_optimal_jobs() {
    cores=$(nproc)
    if [ "$cores" -le 2 ]; then
        echo 2
    elif [ "$cores" -gt 4 ]; then
        echo 4
    else echo $((cores - 1)); fi
}
PARALLEL_JOBS=$(get_optimal_jobs)

# Thumbnail generation
process_func_def='process_image() {
    image="$1"
    filename=$(basename "$image")
    cache_file="${cacheDir}/${filename}"
    md5_file="${cacheDir}/.${filename}.md5"
    lock_file="${cacheDir}/.lock_${filename}"
    current_md5=$(xxh64sum "$image" | cut -d " " -f1)
    (
        flock -x 9
        if [ ! -f "$cache_file" ] || [ ! -f "$md5_file" ] || [ "$current_md5" != "$(cat "$md5_file" 2>/dev/null)" ]; then
            if magick "$image" -resize 500x500^ -gravity center -extent 500x500 "$cache_file"; then
                echo "$current_md5" > "$md5_file"
            else
                echo "⚠️ Failed to generate thumbnail: $image"
                rm -f "$cache_file"
            fi
        fi
        rm -f "$lock_file"
    ) 9>"$lock_file"
}'

export process_func_def cacheDir

rm -f "$cacheDir"/.lock_* 2>/dev/null || true

# Generate thumbnails
find "$wall_dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -print0 |
    xargs -0 -P "$PARALLEL_JOBS" -I {} sh -c "$process_func_def; process_image \"{}\""

# Clean orphaned thumbs
for cached in "$cacheDir"/*; do
    [ -f "$cached" ] || continue
    original="$wall_dir/$(basename "$cached")"
    [ ! -f "$original" ] && rm -f "$cached" "$cacheDir/.lock_$(basename "$cached")" "$cacheDir/.$(basename "$cached").md5"
done

rm -f "$cacheDir"/.lock_* 2>/dev/null || true

# lWallpaper selection
wall_selection=$(find "$wall_dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -print0 |
    xargs -0 -I {} basename "{}" |
    LC_ALL=C sort |
    while IFS= read -r name; do
        thumb="$cacheDir/$name"
        if [ -f "$thumb" ] && file "$thumb" | grep -qE 'image|bitmap'; then
            printf '%s\000icon\037%s\037text\037%s\n' "$name" "$thumb" "$name"
        fi
    done | $rofi_command)

if [ -n "$wall_selection" ]; then
    selected_wall="$wall_dir/$wall_selection"

    # Play selection sound
    paplay /usr/share/sounds/freedesktop/stereo/dialog-information.oga &

    # Add common binary paths
    export PATH="$PATH:/home/ravish/.cargo/bin:/usr/local/bin:/usr/bin"
    # If an image was selected
    # Set wallpaper using swww with transition
    swww img "$selected_wall" --transition-type=wave --transition-step 20 --transition-fps 60 &

    matugen image "$selected_wall"

    wal -n -i "$selected_wall"

    killall swaync
    sleep 0.5
    swaync &

    # Finally send the notification
    notify-send -i "$selected_wall" "Theme Updated"
    sleep 4
    walogram -B

fi
