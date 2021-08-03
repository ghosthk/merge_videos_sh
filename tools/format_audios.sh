#!/bin/bash

rootDir=$(dirname "$0")
source $rootDir/tool.sh

argsCount=($# -ge 1)

if [[ $argsCount < 1 ]]; then
	error "请输入参数 例如: ./format_audios.sh 音频文件夹 目标文件夹[可选,音频文件夹/format]"
fi

audioDir=$1
targetDir=$2
if [[ $argsCount < 2 ]]; then
	targetDir="${audioDir}/format"
fi

if [[ ! -d $targetDir ]]; then
	mkdir $targetDir
fi
log "准备格式化音频 路径:${audioDir} 生成路径:${targetDir}"

audioList=($(ls $1/*.{[mM][pP][3],[mM][4][aA],[fF][lL][aA][cC]}))
audioCount=${#audioList[@]}
log "找到${audioCount}个音频"

index=1
for i in ${audioList[@]}; do
	fileName=$(basename "$i")
	extension=${fileName##*.}
	fileName="${fileName%.*}.m4a"

	log "格式化第${index}/${audioCount}个音频，处理可能较慢，请稍等..."
	targetFilePath=$targetDir/$fileName
	if [[ ! -e $targetFilePath ]]; then
		if [[ $extension = 'm4a' || $extension = 'M4A' ]]; then
			cp $i $targetFilePath
		else 
			ffmpeg -i $i -c:a aac -vn -y $targetFilePath -hide_banner -loglevel $ffmpegLeve
		fi
	fi
	index=`expr $index + 1`
done
log "格式化音频完成 ${targetDir}"