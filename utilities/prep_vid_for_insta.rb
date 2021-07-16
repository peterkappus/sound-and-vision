#!/usr/bin/ruby

#check README for tips on recording video & audio
#once recorded, use this to crop and copy to iCloud Drive
#then save to camera roll on phone and upload to insta via app

dimensions="1080:1920"

input_file = ARGV[0]

fade_start = ARGV[1].to_i
fade_duration = ARGV[2].to_i
total_duration = fade_start + fade_duration

output_file ="video_#{`date +%Y-%m-%dT%H%M`.chomp}.mp4" 
# *IMPORTANT* the "-ac 2" bit converts my weird quad audio (from my audio interface) into stereo. Otherwise, you won't get any sound on Instagram. (the horror!)
#docker run -i -v "$(pwd)":/data jrottenberg/ffmpeg  -i /data/$1 -af "afade=t=out:st=$fadestart:d=$fadeDuration" -vf "fade=t=out:st=$fadestart:d=$fadeDuration,scale=$dimensions:force_original_aspect_ratio=decrease,pad=$dimensions:(ow-iw)/2:(oh-ih)/2,setsar=1" -ac 2 /data/$out_video
#The above will crop to $dimensions and add padding if required
#Or just crop (no scaling... probably better quality): `ffmpeg -i in.mp4 -filter:v "crop=$dimensions:0:0" -c:a copy out.mp4`
#`docker run -i -v "$(pwd)":/data jrottenberg/ffmpeg  -i /data/#{input_file} -af "afade=t=out:st=#{fade_start}:d=#{fade_duration}" -vf "fade=t=out:st=#{fade_start}:d=#{fade_duration},crop=#{dimensions}" -t #{total_duration} -ac 2 /data/#{output_file}`
#`docker run -i -v "$(pwd)":/data jrottenberg/ffmpeg  -i /data/#{input_file} -t #{end_time} -ac 2 /data/#{output_file}`

`docker run -i -v "$(pwd)":/data jrottenberg/ffmpeg  -i /data/#{input_file} -af "compand=.3|.3:1|1:-90/-60|-60/-40|-40/-30|-20/-20:6:5:-90:0.2,afade=t=out:st=#{fade_start}:d=#{fade_duration}" -vf "fade=t=out:st=#{fade_start}:d=#{fade_duration},crop=#{dimensions}" -t #{total_duration} -ac 2 /data/#{output_file}`

#copy to our icloud files
`cp #{output_file} "/Users/peterk/Library/Mobile\ Documents/com~apple~CloudDocs/instagram/#{output_file}"`

#open the new file to check it out and bask in its majesty!
`open "/Users/peterk/Library/Mobile\ Documents/com~apple~CloudDocs/instagram/#{output_file}"`

#open the folder too, just for good measure (and to faciitate deleting old files)
`open /Users/peterk/Library/Mobile\ Documents/com~apple~CloudDocs/instagram/`