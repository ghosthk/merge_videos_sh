#!/bin/bash

(./arg_check.sh $@)
lastShellStatus=$?
if [[ $lastShellStatus -ne 0 ]]; then
	exit -1;
fi

set -x

tempDir=$1/temp
mkdir $tempDir

mp3List=$(ls $1/*.{[mM][pP][3],[mM][4][aA],[fF][lL][aA][cC]})
for i in $mp3List; do
	fileName=$(basename -- "$i")
	extension=${fileName##*.}
	fileName=${fileName%.*}.mp3
	newName=resize_$fileName;
	echo "start resize mp3 $fileName to $newName"
	if [[ $extension == 'mp3' ]]; then
		cp $i $tempDir/$newName
	else 
		ffmpeg -i $i -y $tempDir/$newName
	fi
done
echo 'resize mp4 files finished!!!!'