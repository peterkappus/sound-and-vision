#!/bin/bash

# assemble an audio file and video file into a single video.


audio=$1;
video=$2;

trimmed_audio="trimmed_$audio";

out_video="video_"$(date +%Y-%m-%dT%H%M)".m4a" 

#strip science at the beginning and end
#sox $audio $trimmed_audio silence 1 0.1 0.002% 1 0.1 0.03%
sox $audio $trimmed_audio silence 1 0.1 0.05% 1 0.1 0.03%
#sox $audio $trimmed_audio silence 1 0.1 0.002% 1 0.1 3% compand 0.3,1 6:−70,−60,−20 −5 −90 0.2
#sox $audio $trimmed_audio silence 1 0.1 0.002% 1 0.1 3% contrast 80

#use docker and combine audio & video
#-shortest flag cuts to length of shortest asset
docker run -i -v "$(pwd)":/data jrottenberg/ffmpeg -y -i /data/$video -i /data/$trimmed_audio -shortest /data/$out_video

#copy to iCloud account
cp $out_video /Users/peterk/Library/Mobile\ Documents/com~apple~CloudDocs/$out_video
