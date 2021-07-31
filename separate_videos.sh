#!/bin/bash

if [[ $argsCount < 2 ]]; then
	echo "Please input argumetns, example: crop_audio.sh audio_path start_time duration_time"
    exit -1
fi

dir=$1
mp4List=$(ls $dir/*.{[mM][pP][4],[mM][o0][vV]})

everyClipDuration=60

videocount=${#mp4FileList[@]}

echo "Searched ${videocount} video files";

videosdir=$dir/videos
audiosDir=$dir/audios
separateVideoDir=$videosdir/separateVideos
mkdir $videosdir
mkdir $audiosDir
mkdir $separateVideoDir

for i in $mp4List; do
	# 文件名
	fileName=$(basename "$i" .mp4)

	echo $fileName
	audioPath=$audiosDir/$fileName.m4a
	videoPath=$videosdir/$fileName.mp4
	# 导出 audio 以及MP4
	if [[ ! -e $audioPath ]]; then
		ffmpeg -i $i -acodec copy -vn -y $audioPath
	fi
	
	if [[ ! -e $videoPath ]]; then
		ffmpeg -i $i -vcodec copy -an -y $videoPath
	fi

	# continue;
	#获取MP4时间
	# durationTime=$(ffmpeg -i $videoPath 2>&1 | grep Duration | awk '{print $2}' | tr -d ,)
	durationTime=$(ffmpeg -i $videoPath 2>&1 | grep "Duration"| cut -d ' ' -f 4 | sed s/,// | sed 's@\..*@@g' | awk '{ split($1, A, ":"); split(A[3], B, "."); print 3600*A[1] + 60*A[2] + B[1] }')

	separateCount=`expr $durationTime / 60`

	echo $durationTime
	clipCount=0
	clipDuration=0

	filelog="${separateVideoDir}/${fileName}_log.log"
	if [[ -e $separateVideoPath ]]; then
		rm $filelog
	fi
	while [[ $clipDuration -lt $durationTime ]]; do
		clipCount=`expr $clipCount + 1`
		separateVideoPath="${separateVideoDir}/${fileName}_${clipCount}.mp4"
		tStartTime=$clipDuration
		tDurationTime=$everyClipDuration
		clipDuration=`expr $clipDuration + $everyClipDuration`
		echo $clipCount - $tStartTime - $tDurationTime - $clipDuration
		if [[ $clipDuration -lt $durationTime ]]; then
			echo $clipDuration - $durationTime
		fi
		if [[ ! -e $separateVideoPath ]]; then
			if [[ $clipDuration -gt $durationTime ]]; then
				tDurationTime=`expr $durationTime - $tStartTime`
			fi
			ffmpeg -i $videoPath -vcodec copy -acodec copy -ss $tStartTime -t $tDurationTime -avoid_negative_ts make_zero -y $separateVideoPath
		fi

		printf "第${clipCount}个视频:开始时间:${tStartTime};持续时间:${tDurationTime}\n" >> $filelog; 
	done
	# break;
done