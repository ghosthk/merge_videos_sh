#!/bin/bash

(./arg_check.sh $@)
lastShellStatus=$?
if [[ $lastShellStatus -ne 0 ]]; then
	exit -1;
fi

directory=$1;
videoListName="videolist.txt"
outputFileName="all.mp4"

tempDir=$directory/temp
mkdir $tempDir

videoListPath=$tempDir/$videoListName

rm $videoListPath;

mp4FileList=($(ls $tempDir/resize_*.mp4));

videocount=${#mp4FileList[@]}

echo "Searched ${videocount} video files";

if [[ $videocount == 0 ]]; then
	echo "Please check sub mp4 files is exist...";
	exit -1;
fi

for ((i=0; i<$videocount; i++)); do 
	printf "file '${tempDir}/resize_${i}.mp4'\n" >> $videoListPath; 
done;

echo 'start merge videos...'
ffmpeg -f concat -safe 0 -i $videoListPath -c copy -y $tempDir/$outputFileName

echo 'merge videos finished....'