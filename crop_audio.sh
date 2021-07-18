#!/bin/bash

argsCount=($# -ge 1)

if [[ $argsCount < 2 ]]; then
	echo "Please input argumetns, example: crop_audio.sh audio_path start_time duration_time"
    exit -1
fi

filePath=$1
startTime=00:00:00
durationTime=$2

echo $argsCount

if [[ $argsCount -ge 3 ]]; then
	startTime=$2;
	durationTime=$3;
fi

tempFile=${filePath%/*}/temp_$(basename ${filePath})

echo $startTime 
echo $durationTime

ffmpeg -i $filePath -vn -acodec copy -ss $startTime -t $durationTime -y $tempFile

rm $filePath
mv $tempFile $filePath