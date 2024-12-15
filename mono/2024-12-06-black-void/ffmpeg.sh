ffmpeg -f lavfi -i color=color=black:size=1920x1080:rate=30 -t 300 -c:v libx264 -pix_fmt yuv420p -crf 18 black_void.mp4
