#!/bin/bash

audio=$1;
video=$2;

trimmed_audio="trimmed_$audio";

out_video="video_"$(date +%Y-%m-%dT%H%M)".mp4" 

#strip science at the beginning and end
#sox $audio $trimmed_audio silence 1 0.1 0.002% 1 0.1 0.03%
sox $audio $trimmed_audio silence 1 0.1 0.05% 1 0.1 0.03%
#sox $audio $trimmed_audio silence 1 0.1 0.002% 1 0.1 3% compand 0.3,1 6:−70,−60,−20 −5 −90 0.2
#sox $audio $trimmed_audio silence 1 0.1 0.002% 1 0.1 3% contrast 80

#use docker and combine audio & video
#-shortest flag cuts to length of shortest asset
#d=X (fade-in time)
#start fading at 14 seconds (duration: 1 second)
#limit to 15 seconds long (-t 00:00:15)
docker run -i -v "$(pwd)":/data jrottenberg/ffmpeg -y -i /data/$video -i /data/$trimmed_audio -vf "fade=t=in:st=0:d=0.5,fade=t=out:st=14:d=0.5" -af "afade=t=out:st=14:d=0.5" -t 00:00:15 -shortest /data/$out_video

# colorkey compositing....
#ffmpeg -i <base-video> -i <overlay-video> -filter_complex '[1:v]colorkey=0x<color>:<similarity>:<blend>[ckout];[0:v][ckout]overlay[out]' -map '[out]' <output-file>
  
#ffmpeg -i video.mp4 -vf "fade=t=in:st=0:d=3" -c:a copy out.mp4

#copy to iCloud account
cp $out_video /Users/$USER/Library/Mobile\ Documents/com~apple~CloudDocs/$out_video
