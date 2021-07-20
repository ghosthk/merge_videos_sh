#!/bin/bash

(./arg_check.sh $@)
lastShellStatus=$?
if [[ $lastShellStatus -ne 0 ]]; then
	exit -1;
fi

directory=$1;
videoListName="videolist.txt"
outputFileName="all.mp4"

rm $directory/$videoListName;

outputDir=$directory/output

mp4FileList=($(ls $outputDir/*.mp4));

videocount=${#mp4FileList[@]}

echo "Searched ${videocount} video files";

if [[ $videocount == 0 ]]; then
	echo "Please check sub mp4 files is exist...";
	exit -1;
fi

for ((i=0; i<$videocount; i++)); do 
	printf "file '${outputDir}/simple_${i}.mp4'\n" >> $directory/$videoListName; 
done;

echo 'start merge videos...'
ffmpeg -f concat -safe 0 -i $directory/$videoListName -c copy -y $outputDir/$outputFileName

echo 'merge videos finished....'