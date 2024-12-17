#!/bin/bash

# Function to display usage instructions
usage() {
    echo "Usage: $0 <input_file> <output_file>"
    echo "Rotate a video 90 degrees clockwise."
    echo "Example: $0 input.mp4 output_rotated.mp4"
    exit 1
}

# Check if both input and output file arguments are provided
if [[ -z "$1" || -z "$2" ]]; then
    echo "Error: Missing arguments."
    usage
fi

input_file="$1"
output_file="$2"

# Check if the input file exists
if [[ ! -f "$input_file" ]]; then
    echo "Error: Input file '$input_file' does not exist."
    exit 1
fi

# Rotate the video 90 degrees clockwise using FFmpeg
ffmpeg -i "$input_file" -vf "transpose=1" -c:a copy "$output_file"

# Check if FFmpeg succeeded
if [[ $? -eq 0 ]]; then
    echo "Success: Video rotated 90 degrees clockwise and saved to '$output_file'."
else
    echo "Error: FFmpeg failed to rotate the video."
    exit 1
fi

