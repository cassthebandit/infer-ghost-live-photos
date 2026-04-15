#!/bin/zsh
# Convert to Ghost MP4 — macOS Automator Quick Action
# Two-pass H.264 encode, no audio, metadata stripped.
# Right-click any .mov → Quick Actions → Convert to Ghost MP4
# Output: same folder, filename_ghost.mp4

for f in "$@"; do
    dir=$(dirname "$f")
    name=$(basename "$f")
    base="${name%.*}"
    output="${dir}/${base}_ghost.mp4"
    passlog=$(mktemp -d)/ffmpeg2pass

    /opt/homebrew/bin/ffmpeg -i "$f" \
        -an \
        -map_metadata -1 \
        -c:v libx264 \
        -b:v 4M \
        -pass 1 \
        -passlogfile "$passlog" \
        -pix_fmt yuv420p \
        -movflags +faststart \
        -f null /dev/null && \
    /opt/homebrew/bin/ffmpeg -i "$f" \
        -an \
        -map_metadata -1 \
        -c:v libx264 \
        -b:v 4M \
        -pass 2 \
        -passlogfile "$passlog" \
        -pix_fmt yuv420p \
        -movflags +faststart \
        "$output"

    rm -rf "$(dirname "$passlog")"
done
