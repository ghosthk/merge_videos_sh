#!/bin/bash

(./arg_check.sh $@)
lastShellStatus=$?
if [[ $lastShellStatus -ne 0 ]]; then
	exit -1;
fi

directory=$1;
videoListName="videolist.txt"
outputFileName="output.mp4"

rm $directory/$videoListName;

mp3FileList=($(ls $directory/*.mp3));

videocount=${#mp3FileList[@]}

echo "Searched ${videocount} video files";

if [[ $videocount == 0 ]]; then
	echo "Please check sub mp4 files is exist...";
	exit -1;
fi

for ((i=0; i<$videocount; i++)); do 
	printf "file '${directory}/${i}.mp4'\n" >> $directory/$videoListName; 
done;

echo 'start merge videos...'
ffmpeg -f concat -safe 0 -i $directory/$videoListName -c copy -y $directory/$outputFileName

echo 'merge videos finished....'