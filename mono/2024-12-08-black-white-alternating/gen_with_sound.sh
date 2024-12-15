#!/bin/bash

# https://chatgpt.com/c/6752d54d-9aa4-8009-9819-2c0e4528b19c

# Output filenames
portrait_output="black_white_alternating_1080x1920.mp4"
landscape_output="black_white_alternating_1920x1080.mp4"

# Generate the alternating black and white video for portrait (1080x1920)
ffmpeg -f lavfi -i "color=color=black:size=1080x1920:rate=1:d=1" \
       -f lavfi -i "color=color=white:size=1080x1920:rate=1:d=1" \
       -filter_complex "[0:v][1:v]concat=n=2:v=1:a=0" \
       -t 2 temp_bw_1080x1920.mp4

# Generate the alternating black and white video for landscape (1920x1080)
ffmpeg -f lavfi -i "color=color=black:size=1920x1080:rate=1:d=1" \
       -f lavfi -i "color=color=white:size=1920x1080:rate=1:d=1" \
       -filter_complex "[0:v][1:v]concat=n=2:v=1:a=0" \
       -t 2 temp_bw_1920x1080.mp4

# Generate 1-second silence and 1-second 220 Hz sine wave audio
ffmpeg -f lavfi -i anullsrc=d=1:r=48000:cl=mono \
       -f lavfi -i "sine=frequency=220:duration=1:sample_rate=48000" \
       -filter_complex "[0:a][1:a]concat=n=2:v=0:a=1" \
       -t 2 temp_audio.wav

# Loop the audio to 10 minutes
ffmpeg -stream_loop 299 -i temp_audio.wav \
       -t 600 -c:a aac -b:a 128k temp_audio_10min.aac

# Combine portrait video and audio
ffmpeg -stream_loop 299 -i temp_bw_1080x1920.mp4 \
       -i temp_audio_10min.aac \
       -t 600 -c:v libx264 -pix_fmt yuv420p -c:a aac -b:a 128k "$portrait_output"

# Combine landscape video and audio
ffmpeg -stream_loop 299 -i temp_bw_1920x1080.mp4 \
       -i temp_audio_10min.aac \
       -t 600 -c:v libx264 -pix_fmt yuv420p -c:a aac -b:a 128k "$landscape_output"

# Clean up temporary files
rm temp_bw_1080x1920.mp4 temp_bw_1920x1080.mp4 temp_audio.wav temp_audio_10min.aac

echo "Videos generated:"
echo "- $portrait_output"
echo "- $landscape_output"
