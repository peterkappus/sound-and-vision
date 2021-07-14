#!/bin/bash

#check README for tips on recording video & audio
#once recorded, use this to crop and copy to iCloud Drive
#then save to camera roll on phone and upload to insta via app

fadestart=$2
fadeDuration=$3
out_video="video_"$(date +%Y-%m-%dT%H%M)".mp4" 
docker run -i -v "$(pwd)":/data jrottenberg/ffmpeg  -i /data/$1 -af "afade=t=out:st=$fadestart:d=$fadeDuration" -vf "fade=t=out:st=$fadestart:d=$fadeDuration,scale=480:720:force_original_aspect_ratio=decrease,pad=480:720:(ow-iw)/2:(oh-ih)/2,setsar=1" -ac 2 /data/$out_video

#The above will crop to 480:720 (great for Instagram) and add padding if required. Also *IMPORTANT* the "-ac 2" bit converts my weird quad audio (from my audio interface) into stereo. Otherwise, you won't get any sound on Instagram. (the horror!)
#Or just crop (no scaling... probably better quality): `ffmpeg -i in.mp4 -filter:v "crop=1280:720:0:0" -c:a copy out.mp4`

cp $out_video /Users/peterk/Library/Mobile\ Documents/com~apple~CloudDocs/instagram/$out_video
open /Users/peterk/Library/Mobile\ Documents/com~apple~CloudDocs/instagram/$out_video