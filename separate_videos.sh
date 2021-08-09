#!/bin/bash

rootDir=$(dirname "$0")
source $rootDir/tools/tool.sh

($rootDir/tools/arg_check.sh $@)

setupLog

dir=$1
shopt -s nullglob
videoList=( $dir/*.{[mM][pP][4],[mM][o0][vV]} )
shopt -u nullglob

videocount=${#videoList[@]}

log "准备分离 ${dir} 目录下的所有视频"
log "找到 ${videocount} 个视频";

# exit 1
videosdir=$separateVideoDir
audiosDir=$separateAudioDir

index=0 
for i in ${videoList[@]}; do
	index=`expr $index + 1`
	# 文件名
	fileName=$(basename "$i")
	extension=${fileName##*.}
	fileName="${fileName%.*}"

	log "开始分离第 ${index}/${videocount} 个视频, 文件名: ${fileName}"
	audioPath=$audiosDir/$fileName.m4a
	videoPath=$videosdir/$fileName.mp4
	
	# 导出 audio 以及MP4
	if [[ ! -e $audioPath ]]; then
		log "开始分离音频: 分离之后音频路径: ${audioPath}"
		tAudioPath=$audiosDir/$fileName.temp.m4a
		ffmpeg -i $i -acodec copy -vn -y $tAudioPath  -hide_banner -loglevel $ffmpegLeve
		mv $tAudioPath $audioPath
	else
		log "开始分离音频: 音频已存在: ${videoPath}"
	fi
	
	if [[ ! -e $videoPath ]]; then
		log "开始分离视频: 分离之后视频路径: ${videoPath}"
		tVideoPath=$videosdir/$fileName.temp.mp4
		ffmpeg -i $i -vcodec copy -an -preset fast -y $tVideoPath -hide_banner -loglevel $ffmpegLeve
		mv $tVideoPath $videoPath
	else
		log "开始分离视频: 视频已存在: ${videoPath}"
	fi

	if [[ -e $videoPath ]]; then
		log "视频存在，则开始裁剪视频"
		($rootDir/clip_video.sh $videoPath)
	else
		warning "视频不存在，可能分离产生了问题"
	fi
done

log "分离完了所有视频。"
log "分离的音频目录: ${separateAudioDir}"
log "分离的视频目录: ${separateVideoDir}"
log "裁剪视频的目录: ${clipVideoDir}"
log "视频素材的目录: ${videosResouceDir}"
log "如果裁剪视频的素材没问题，可以将新生成的素材移动到视频素材目录，供之后的视频使用^_^"
