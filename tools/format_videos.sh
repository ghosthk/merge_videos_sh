#!/bin/bash

rootDir=$(dirname "$0")
source $rootDir/tool.sh

argsCount=($# -ge 1)

if [[ $argsCount < 1 ]]; then
	error "请输入参数 例如: ./format_videos.sh 视频文件夹 目标文件夹[可选,视频文件夹/format]"
fi

videoDir=$1
targetDir=$2
if [[ $argsCount < 2 ]]; then
	targetDir="${videoDir}/format"
fi

if [[ ! -d $targetDir ]]; then
	mkdir $targetDir
fi
log "准备格式化视频 路径:${videoDir} 生成路径:${targetDir}"

shopt -s nullglob
videoList=( $1/*.{[mM][pP][4],[mM][oO][vV]} )
shopt -u nullglob

videoCount=${#videoList[@]}
log "找到${videoCount}个视频"

index=1
for i in ${videoList[@]}; do
	fileName=$(basename "$i")
	extension=${fileName##*.}
	fileName="${fileName%.*}.mp4"

	log "格式化第${index}/${videoCount}个视频，处理可能较慢，请稍等..."
	targetFilePath=$targetDir/$fileName
	if [[ ! -e $targetFilePath ]]; then
		ffmpeg -i $i -s "${videoWidth}x${videoHeight}" -r 30000/1001 -video_track_timescale 30k -vcodec h264 -acodec mp2 -crf 23 -maxrate 2M -bufsize 2M -pix_fmt yuvj420p -brand mp42 -preset fast -y $targetFilePath -hide_banner -loglevel $ffmpegLeve
	fi
	index=`expr $index + 1`
done
log "格式化视频完成 ${targetDir}"
open ${targetDir}