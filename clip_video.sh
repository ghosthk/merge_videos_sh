#!/bin/bash

rootDir=$(dirname "$0")
source $rootDir/tools/tool.sh

($rootDir/tools/arg_check.sh $@)

filePath=$1
# 获取路径
fileDir=${filePath%/*}
# 获取文件名不带扩展
fileName=$(basename "$filePath")
fileName="${fileName%.*}"

#获取视频时长
allDurationTime=$(ffmpeg -i $filePath 2>&1 | grep "Duration"| cut -d ' ' -f 4 | sed s/,// | sed 's@\..*@@g' | awk '{ split($1, A, ":"); split(A[3], B, "."); print 3600*A[1] + 60*A[2] + B[1] }')
log "裁剪的视频文件名: ${fileName} 视频时长:${allDurationTime} 视频路径: ${filePath}"

#
outputDir=$clipVideoDir
log "导出视频文件路径: "$outputDir

# 删除当前作品历史导出数据(由于视频都是裁剪一分钟左右的，所以之前已经裁剪过了之后的判断不会再次进行裁剪的)
# oldClipVideos=($(ls $outputDir/$fileName*.*))
# log "找到 ${#oldClipVideos[@]} 个历史裁剪记录将被删除: ${oldClipAudios[@]}"
# if [[ ${#oldClipVideos[@]} -gt 0 ]]; then
# 	rm ${oldClipVideos[@]}
# fi

separateCount=`expr $allDurationTime / $everyClipDuration + 1`

log "${everyClipDuration}秒裁剪一次，预计要裁剪${separateCount}个视频。"

clipCount=0 
clipDuration=0 
while [[ $clipDuration -lt $allDurationTime ]]; do
	clipCount=`expr $clipCount + 1`

	separateVideoPath="${outputDir}/${fileName}_${clipCount}.mp4"
	tStartTime=$clipDuration
	tDurationTime=$everyClipDuration
	clipDuration=`expr $clipDuration + $everyClipDuration`

	if [[ $clipDuration -gt $allDurationTime ]]; then
		tDurationTime=`expr $allDurationTime - $tStartTime`
	fi
	log "裁剪到第${clipCount}/${separateCount}个视频:开始时间:${tStartTime};持续时间:${tDurationTime}"
	if [[ ! -e $separateVideoPath ]]; then
		ffmpeg -i $filePath -r 30000/1001 -video_track_timescale 30k -vcodec copy -acodec copy -ss $tStartTime -t $tDurationTime -avoid_negative_ts make_zero -y $separateVideoPath -hide_banner -loglevel $ffmpegLeve
	fi
done