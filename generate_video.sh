#!/bin/bash
rootDir=$(dirname "$0")
source $rootDir/tools/tool.sh

argsCount=($# -ge 1)
($rootDir/tools/arg_check.sh $@)

function generate_video() {
	currentIndex=$1
	allCount=$2
	path=$3
	currentProgress="${currentIndex}/${allCount}"
	# 获取目录最后一级名字
	lastDirName=${path##*/}
	# 输出的文件名前缀
	outputFilePrefix=$lastDirName-$(date "+%H%M%S")

	videoPath=$videosResouceDir

	if [[ ! -d $videoPath ]]; then
		error "视频文件夹不存在，请检查路径是否正确. ${videoPath}"
	fi

	shopt -s nullglob
	videosFilePath=( $videoPath/*.mp4 )
	shopt -u nullglob
	videosFileCount=${#videosFilePath[@]}
	if [[ $generateCount == 0 ]]; then
		error "视频文件夹资源个数为{0}，请检查路径是否正确. ${videoPath}"
	fi

	mergeAudiosFilePath=$todayOutputTempDir/$outputFilePrefix-audio-$currentIndex.txt
	mergeVideosFilePath=$todayOutputTempDir/$outputFilePrefix-video-$currentIndex.txt
	mergedAudiosFilePath=$todayOutputTempDir/$outputFilePrefix-$currentIndex.m4a
	mergedVideosFilePath=$todayOutputTempDir/$outputFilePrefix-$currentIndex.mp4
	outputVideoFilePathTemp=$todayOutputTempDir/$outputFilePrefix-$currentIndex-temp.mp4
	outputVideoFilePath=$todayOutputDir/$outputFilePrefix-$currentIndex.mp4

	log "第 ${currentProgress} 视频，准备制作..."

	log "第 ${currentProgress} 视频: 开始格式化音频..."
	audiosPath="${path}/format"
	if [[ ! -d $audiosPath ]]; then
		mkdir $audiosPath
	fi
	(./tools/format_audios.sh $path $audiosPath)

	log "第 ${currentProgress} 视频: 开始合并音频, 可能会比较耗时，请耐心等待..."
	audioFileList=($(ls $audiosPath/*.m4a));
	audiocount=${#audioFileList[@]}
	log "第 ${currentProgress} 视频: 找到 ${audiocount} 个音频文件.";
	if [[ $audiocount == 0 ]]; then
		log "第 ${currentProgress} 视频: 音频个数不对，请检查...."
		continue
	fi

	for ((i=0; i<$audiocount; i++)); do 
		audioFilePathTemp="${audiosPath}/${i}.m4a"
		writeFilesToPath $audioFilePathTemp $mergeAudiosFilePath
	done

	mergeAVFiles $mergeAudiosFilePath $mergedAudiosFilePath

	if [[ ! -e $mergedAudiosFilePath ]]; then
		log "第 ${currentProgress} 视频: 合并音频失败..."
		continue
	fi

	audiosDuration=$(getFileDuration $mergedAudiosFilePath)

	log "第 ${currentProgress} 视频: 合并音频成功 时长: ${audiosDuration}"

	log "第 ${currentProgress} 视频: 开始随机视频资源..."

	# 随机分配视频资源
	usedVideoFileIndexs=()
	videosDuration=0
	randomVideoIndex=0
	while [[ $videosDuration -lt $audiosDuration ]]; do
		randomVideoValue=0
		randomVideoFinished=0
		while [[ $randomVideoFinished -eq 0 ]]; do
			usedVideoFileCount=${#usedVideoFileIndexs[@]}
			randomVideoValue=$[$RANDOM%$videosFileCount]
			# 如果记录的个数已经到达视频总个数，则随机生成重复使用。
			if [[ $usedVideoFileCount == videosFileCount ]]; then
				randomVideoFinished=1
			else
				if [[ ! " ${usedVideoFileIndexs[@]} " =~ " ${randomVideoValue} " ]]; then
					# log "音频未包含 ${randomVideoValue}则添加"
					randomVideoFinished=1
				else
					# log "音频已包含 ${randomVideoValue}"
					randomVideoFinished=0
				fi
			fi
		done
		usedVideoFileIndexs[$randomVideoIndex]=$randomVideoValue
		videoPathTemp=${videosFilePath[randomVideoValue]}
		
		writeFilesToPath $videoPathTemp $mergeVideosFilePath
		
		videoDuration=$(getFileDuration $videoPathTemp)
		videosDuration=$(( $videosDuration + $videoDuration ))

		videoName=$(basename "$videoPathTemp")
		randomVideoIndex=`expr $randomVideoIndex + 1`

		log "第 ${currentProgress} 视频: 选取了第${randomVideoIndex}个视频:${videoName} 时长:${videoDuration}s 总时长:${videosDuration}"
	done

	log "第 ${currentProgress} 视频：开始合成视频, 可能会比较耗时，请耐心等待..."
	mergeAVFiles $mergeVideosFilePath $mergedVideosFilePath

	if [[ ! -e $mergedVideosFilePath ]]; then
		log "第 ${currentProgress} 视频: 合成视频失败..."
		continue
	fi

	log "第 ${currentProgress} 视频：开始合并音视频, 可能会比较耗时，请耐心等待..."
	($rootDir/tools/merge_audio_video.sh $mergedAudiosFilePath $mergedVideosFilePath $outputVideoFilePathTemp)

	mv $outputVideoFilePathTemp $outputVideoFilePath

	log "第 ${currentProgress} 视频：移除产生的临时文件"
	rm -rf $audiosPath
	rm $mergeVideosFilePath
	rm $mergeAudiosFilePath
	rm $mergedAudiosFilePath
	rm $mergedVideosFilePath

	log "****************************************"
	if [[ -e $outputVideoFilePath ]]; then
		log "第 ${currentProgress} 视频：合并音视频成功. 请查看 ${outputVideoFilePath}"
	else
		log "第 ${currentProgress} 视频：合并音视频失败..."
	fi
	log "****************************************"
	log ""
	log ""
}

log "一共要生成 ${argsCount} 个视频"
makeOutputDir
index=1
for arg in $@; do
	generate_video $index $argsCount $arg
	index=`expr $index + 1`
done

log "生成完了所有视频，可能存在部分视频失败或有问题，麻烦一个个视频简单查验下^_^"
log "导出视频的目录: ${todayOutputDir}"
log "如果生成的视频已经使用，可以删除当前文件夹^_^ ${todayOutputDir}"
open ${todayOutputDir}