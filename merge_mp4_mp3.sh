#!/bin/bash

(./arg_check.sh $@)
lastShellStatus=$?
if [[ $lastShellStatus -ne 0 ]]; then
	exit -1;
fi

directory=$1;
videoListName="videolist.txt"
outputFileName=${directory##*/}.mp4

outputDir=$directory/output
mkdir $outputDir

tempDir=$directory/temp
mp4Path=$tempDir/all.mp4
audioPath=$tempDir/all.mp3
echo $mp4Path
echo $audioPath
outputMp4Path=$outputDir/$outputFileName

ffmpeg -stream_loop -1 -i $mp4Path -i $audioPath -map 0:v:0 -map 1:a:0 -c:a aac -crf 23 -maxrate 2M -bufsize 2M -pix_fmt yuvj420p -brand mp42 -preset fast -shortest -y $outputMp4Path