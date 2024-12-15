# landscape (for youtube)
ffmpeg -f lavfi -i color=color=white:size=1920x1080:rate=30 -t 300 -c:v libx264 -pix_fmt yuv420p -crf 18 white_void.mp4

# portrait (for ig reels)
ffmpeg -f lavfi -i color=color=white:size=1080x1920:rate=30 -t 300 -c:v libx264 -pix_fmt yuv420p -crf 18 white_void_portrait.mp4
