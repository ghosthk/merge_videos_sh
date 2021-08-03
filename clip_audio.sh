#!/bin/bash

source $(dirname "$0")/tools/tool.sh

argsCount=($# -ge 1)

if [[ $argsCount < 2 ]]; then
	error "请输入参数 例如: ./clip_audio.sh 音频路径 第一段秒数 第二段秒数 第三段秒数 ...."
fi

filePath=$1
# 获取路径
fileDir=${filePath%/*}
# 获取文件名不带扩展
fileName=$(basename "$filePath")
fileName="${fileName%.*}"

#获取音频时长
allDurationTime=$(ffmpeg -i $filePath 2>&1 | grep "Duration"| cut -d ' ' -f 4 | sed s/,// | sed 's@\..*@@g' | awk '{ split($1, A, ":"); split(A[3], B, "."); print 3600*A[1] + 60*A[2] + B[1] }')
log "裁剪的音频文件名: ${fileName} 音频时长:${allDurationTime} 音频路径: ${filePath}"

#
outputDir=$clipAudioDir
log "导出音频文件路径: "$outputDir

# 删除当前作品历史导出数据
oldClipAudios=($(ls $outputDir/$fileName*.*))
log "找到 ${#oldClipAudios[@]} 个历史裁剪记录将被删除: ${oldClipAudios[@]}"
if [[ ${#oldClipAudios[@]} -gt 0 ]]; then
	rm ${oldClipAudios[@]}
fi

# 获取所有时间
times=( "$@" )
unset times[0]
timesCount=${#times[@]}

log "要裁剪的时间: ${times[*]}" 

lastClipSec=0 
for ((i=0; i<=$timesCount; i++)); do
	currentCount=`expr $i + 1`
	currentSec=${times[$currentCount]}
	tFilePath="${outputDir}/${fileName}_${currentCount}_${times[$currentCount]}.m4a"

	log "第${currentCount}/`expr 1 + ${timesCount}`次裁剪，导出路径:${tFilePath}"

	if [[ $currentSec -ge $allDurationTime ]]; then
		error "时间 ${currentSec} 配置有问题，总时长只有${allDurationTime}"
	fi

	if [[ $i -eq $timesCount ]]; then
		log "开始裁剪时间:${lastClipSec} 至结束"
		ffmpeg -i $filePath -vn -acodec aac -ss $lastClipSec -y $tFilePath -hide_banner -loglevel $ffmpegLeve
	else
		durationSec=`expr $currentSec - $lastClipSec`
		log "开始裁剪时间:${lastClipSec} 持续时间:${durationSec}"
		ffmpeg -i $filePath -vn -acodec aac -ss $lastClipSec -t $durationSec -y $tFilePath -hide_banner -loglevel $ffmpegLeve
		lastClipSec=$currentSec
	fi
done

log "裁剪音频完成: "$outputDir