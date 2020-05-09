#!/bin/bash

# This script combines an audio and video file into a single video trimming to the length of the shorter item

#parameter 1 is the audio file
audio=$1;

#parameter 2 is the video file
video=$2;

trimmed_audio="trimmed_$audio";

out_video="video_"$(date +%Y-%m-%dT%H%M)".m4a" 

# strip science at the beginning and end
# TODO: use a docker instance for folks who don't have sox installed locally
#sox $audio $trimmed_audio silence 1 0.1 0.002% 1 0.1 0.03%
sox $audio $trimmed_audio silence 1 0.1 0.05% 1 0.1 0.03%
#sox $audio $trimmed_audio silence 1 0.1 0.002% 1 0.1 3% compand 0.3,1 6:−70,−60,−20 −5 −90 0.2
#sox $audio $trimmed_audio silence 1 0.1 0.002% 1 0.1 3% contrast 80

#use docker and combine audio & video
#-shortest flag cuts to length of shortest asset
docker run -i -v "$(pwd)":/data jrottenberg/ffmpeg -y -i /data/$video -i /data/$trimmed_audio -shortest /data/$out_video

#copy to my iCloud drive 
# TODO: check if the user has one of these...
cp $out_video /Users/$USER/Library/Mobile\ Documents/com~apple~CloudDocs/$out_video
