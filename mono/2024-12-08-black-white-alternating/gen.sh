#!/bin/bash

# Output filenames
portrait_output="black_white_alternating_1080x1920.mp4"
landscape_output="black_white_alternating_1920x1080.mp4"

# Generate a 1-second black and white sequence for portrait (1080x1920)
ffmpeg -f lavfi -i "color=color=black:size=1080x1920:rate=1:d=1" \
       -f lavfi -i "color=color=white:size=1080x1920:rate=1:d=1" \
       -filter_complex "[0:v][1:v]concat=n=2:v=1:a=0" \
       -t 2 temp_bw_1080x1920.mp4

# Loop the sequence to make it 10 minutes long
ffmpeg -stream_loop 299 -i temp_bw_1080x1920.mp4 \
       -t 600 -c:v libx264 -pix_fmt yuv420p "$portrait_output"

# Generate a 1-second black and white sequence for landscape (1920x1080)
ffmpeg -f lavfi -i "color=color=black:size=1920x1080:rate=1:d=1" \
       -f lavfi -i "color=color=white:size=1920x1080:rate=1:d=1" \
       -filter_complex "[0:v][1:v]concat=n=2:v=1:a=0" \
       -t 2 temp_bw_1920x1080.mp4

# Loop the sequence to make it 10 minutes long
ffmpeg -stream_loop 299 -i temp_bw_1920x1080.mp4 \
       -t 600 -c:v libx264 -pix_fmt yuv420p "$landscape_output"

# Clean up temporary files
rm temp_bw_1080x1920.mp4 temp_bw_1920x1080.mp4

echo "Videos generated:"
echo "- $portrait_output"
echo "- $landscape_output"
