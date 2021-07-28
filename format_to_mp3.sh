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
	fileName=${fileName%.*}.m4a
	newName=resize_$fileName;
	echo "start resize m4a $fileName to $newName"
	if [[ $extension == 'm4a' ]]; then
		cp $i $tempDir/$newName
	else 
		ffmpeg -i $i -c:a aac -vn -y $tempDir/$newName
	fi
done
echo 'resize m4a files finished!!!!'