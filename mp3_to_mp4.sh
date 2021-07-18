#!/bin/bash

(./arg_check.sh $@)
lastShellStatus=$?
if [[ $lastShellStatus -ne 0 ]]; then
	exit -1;
fi

directory=$1;

set -x

for i in $(ls $directory/*.mp3); do 
	index=$(basename ${i} .mp3); 
	audioPath=$directory/$index.mp3
	imgPath=$directory/temp_$index.jpg
	videoPath=$directory/$index.mp4
	# rcf 输出视频质量0~51 ,0: 无损， 51: 最差  默认23
	# maxrate 调整这个数值来压缩视频大小
	ffmpeg -y -loop 1 -i $imgPath -i $audioPath -r 1 -c:v libx264 -x264-params keyint=1:scenecut=0 -crf 23 -maxrate 400k -bufsize 2M -c:a aac -pix_fmt yuvj420p -brand mp42 -preset fast -shortest $videoPath; 

	durationTime=$(ffmpeg -i $audioPath 2>&1 | grep Duration | awk '{print $2}' | tr -d ,)
	
	tempVideoPath=${videoPath%/*}/temp_$(basename ${videoPath})

	ffmpeg -i $videoPath -vcodec copy -acodec copy -ss 00:00:00 -t $durationTime -y $tempVideoPath

	rm $videoPath
	mv $tempVideoPath $videoPath
done