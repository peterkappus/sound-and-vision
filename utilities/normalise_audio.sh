    # Check if both input and output file arguments are provided
    if [[ -z "$1" || -z "$2" ]]; then
        echo "Usage: normalize_video_audio <input_file> <output_file>"
        echo "Example: normalize_video_audio input.mp4 output.mp4"
        return 1
    fi

    input_file="$1"
    output_file="$2"

    # Check if input file exists
    if [[ ! -f "$input_file" ]]; then
        echo "Error: Input file '$input_file' does not exist."
        return 1
    fi

    # Run FFmpeg with audio normalization (video stream untouched)
    ffmpeg -i "$input_file" -c:v copy -af loudnorm "$output_file"

    # Check if FFmpeg succeeded
    if [[ $? -eq 0 ]]; then
        echo "Success: Audio normalized and saved to '$output_file'."
    else
        echo "Error: FFmpeg failed to normalize the audio."
        return 1
    fi
