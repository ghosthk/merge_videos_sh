#!/bin/bash

(./arg_check.sh $@)
lastShellStatus=$?
if [[ $lastShellStatus -ne 0 ]]; then
	exit -1;
fi

set -x

tempDir=$1/temp
mkdir $tempDir

mp4List=$(ls $1/*.{[mM][pP][4],[mM][o0][vV]})
for i in $mp4List; do
	fileName=$(basename -- "$i")
	extension=${fileName##*.}
	fileName=${fileName%.*}.mp4
	newName=resize_$fileName;
	echo "start resize mp4 $fileName to $newName"
	ffmpeg -i $i -s 1280x720 -r 30000/1001 -video_track_timescale 30k -vcodec h264 -acodec mp2 -crf 23 -maxrate 2M -bufsize 2M -pix_fmt yuvj420p -brand mp42 -preset fast -y $tempDir/$newName
done
echo 'resize mp4 files finished!!!!'