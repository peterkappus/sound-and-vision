# A collection of one-liner utilities to trim, combine, transcode, crop, fade, etc.


# crop a horiz video for instagram

function igcrop() {
	#ffmpeg -i $1 -vf "crop=ih*4/5:ih" -c:a copy $2
	ffmpeg -i $1 -vf "scale='if(gte(iw/ih,9/16),1080,-1)':'if(gte(iw/ih,9/16),-1,1920)',crop=1080:1920,format=yuv420p" -c:a copy $2

}


