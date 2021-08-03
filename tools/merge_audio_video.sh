#!/bin/bash

rootDir=$(dirname "$0")
source $rootDir/tool.sh

argsCount=($# -ge 1)
if [[ $argsCount < 3 ]]; then
	error "请输入参数 例如: ./merge_audio_video 音频路径 视频路径 导出路径"
fi
if [[ ! -e $1 ]]; then
	error "音频文件不存在, 请检查 ${1}"	
fi
if [[ ! -e $2 ]]; then
	error "视频文件不存在, 请检查 ${2}"	
fi
ffmpeg -stream_loop -1 -i $2 -i $1 -map 0:v:0 -map 1:a:0 -acodec copy -vcodec copy -preset fast -shortest -y $3 -hide_banner -loglevel $ffmpegLeve