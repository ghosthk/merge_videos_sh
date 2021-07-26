#!/bin/bash

(./arg_check.sh $@)
lastShellStatus=$?
if [[ $lastShellStatus -ne 0 ]]; then
	exit -1;
fi

directory=$1;
mp3ListName="mp3list.txt"
outputFileName="all.mp3"

tempDir=$directory/temp
mkdir $tempDir

mp3ListPath=$tempDir/$mp3ListName

rm $mp3ListPath;

mp3FileList=($(ls $directory/*.mp3));

mp3count=${#mp3FileList[@]}

echo "Searched ${mp3count} mp3 files";

if [[ $mp3count == 0 ]]; then
	echo "Please check sub mp3 files is exist...";
	exit -1;
fi

for ((i=0; i<$mp3count; i++)); do 
	printf "file '${directory}/${i}.mp3'\n" >> $mp3ListPath; 
done;

echo 'start merge mp3 files...'
ffmpeg -f concat -safe 0 -i $mp3ListPath -c copy -y $tempDir/$outputFileName

echo 'merge mp3 files finished....'