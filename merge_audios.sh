#!/bin/bash

(./arg_check.sh $@)
lastShellStatus=$?
if [[ $lastShellStatus -ne 0 ]]; then
	exit -1;
fi

directory=$1;
audioListName="audiolist.txt"
outputFileName="all.m4a"

tempDir=$directory/temp
mkdir $tempDir

audioListPath=$tempDir/$audioListName

rm $audioListPath;

audioFileList=($(ls $tempDir/resize_*.m4a));

audiocount=${#audioFileList[@]}

echo "Searched ${audiocount} m4a files";

if [[ $audiocount == 0 ]]; then
	echo "Please check sub audio files is exist...";
	exit -1;
fi

echo $audioFileList
echo $audiocount

for ((i=0; i<$audiocount; i++)); do 
	printf "file '${tempDir}/resize_${i}.m4a'\n" >> $audioListPath; 
done;

echo 'start merge audio files...'
ffmpeg -f concat -safe 0 -i $audioListPath -c copy -y $tempDir/$outputFileName

echo 'merge audio files finished....'