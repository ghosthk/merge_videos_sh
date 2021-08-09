#!/bin/bash

rootDir=$(dirname "$0")
source $rootDir/tools/tool.sh

function randomGenerate() {
	argsCount=($# -ge 1)

	if [[ $argsCount < 2 ]]; then
		error "请输入参数 例如: ./random_generate.sh 生成视频个数 音频路径 视频资源路径[可选,默认为~/Downloads/Resources/videos]"
	fi

	generateCount=$1
	audioPath=$2
	videoPath=$videosResouceDir
	if [[ $argsCount > 2 ]]; then
		videoPath=$3
	fi

	python ./rename_files_name.py $audioPath $videoPath

	audioDirName=${audioPath##*/}
	outputFilePrefix=$audioDirName-$(date "+%H%M%S")

	log "将要随机生成 ${generateCount} 个视频"
	log "将在音频文件夹 ${audioPath} 中随机音频"
	log "将在视频文件夹 ${videoPath} 中随机视频"

	if [[ ! -d $audioPath ]]; then
		error "音频文件夹不存在，请检查输入是否正确."
	fi

	if [[ ! -d $videoPath ]]; then
		error "视频文件夹不存在，请检查输入是否正确."
	fi

	shopt -s nullglob
	audiosFilePath=( $audioPath/*.{[mM][pP][3],[mM][4][aA],[fF][lL][aA][cC],[wW][aa][vV]} )
	videosFilePath=( $videoPath/*.mp4 )
	shopt -u nullglob
	audiosFileCount=${#audiosFilePath[@]}
	if [[ $generateCount -gt $audiosFileCount ]]; then
		error "音频文件只有${audiosFileCount}个， 而你需要生成${generateCount}个。"
	else
		log "音频文件夹中有${audiosFileCount}个音频"
	fi
	videosFileCount=${#videosFilePath[@]}
	if [[ $generateCount -gt $videosFileCount ]]; then
		error "视频文件只有${videosFileCount}个， 而你需要生成${generateCount}个。"
	else
		log "视频文件夹中有${videosFileCount}个视频"
	fi

	makeOutputDir

	function IsContains(){
	    # 把原来的arr新赋值给一个新数组
	    narr=($1)
	    # 逻辑是判断删除\$2后的数组是否与原数组相同，不同则标明包含元素，相同（没有\$2可删除）则标明不包含元素
	    [[ ${narr[@]/$2/} != ${narr[@]} ]];log $?
	}

	# 先定义好开头音频与视频
	firstAudioIndexs=()	# 开头音频的索引
	firstVideoIndexs=()	# 开头视频的索引
	firstSetCount=0

	log "开始随机生成每个视频第一个使用的音频与视频，防止最终生成的视频开头重复。可能会比较耗时，请耐心等待...."

	while [[ $firstSetCount -lt $generateCount ]]; do
		# 随机audio
		randomAudioIndex=0
		if [[ $generateCount -eq $audiosFileCount ]]; then
			randomAudioIndex=$firstSetCount
		else
			randomFinished=0
			while [[ $randomFinished -eq 0 ]]; do
				randomAudioIndex=$[$RANDOM%$audiosFileCount]
				if [[ ! " ${firstAudioIndexs[@]} " =~ " ${randomAudioIndex} " ]]; then
					# log "音频未包含 ${randomAudioIndex}则添加"
					randomFinished=1
				else
					# log "音频包含 ${randomAudioIndex}"
					randomFinished=0
				fi
			done
		fi
		firstAudioIndexs[$firstSetCount]=$randomAudioIndex

		# 随机audio
		randomVideoIndex=0
		if [[ $generateCount -eq $videosFileCount ]]; then
			randomVideoIndex=$firstSetCount
		else
			randomFinished=0
			while [[ $randomFinished -eq 0 ]]; do
				randomVideoIndex=$[$RANDOM%$videosFileCount]
				if [[ ! " ${firstVideoIndexs[@]} " =~ " ${randomVideoIndex} " ]]; then
					# log "视频未包含 ${randomVideoIndex}则添加"
					randomFinished=1
				else
					# log "视频包含 ${randomVideoIndex}"
					randomFinished=0
				fi
			done
		fi
		firstVideoIndexs[$firstSetCount]=$randomVideoIndex

		firstSetCount=`expr $firstSetCount + 1`
	done

	log "完成随机每个视频第一个使用的音频与视频"

	log "开始进行随机视频生成"
	for (( i=0; i<$generateCount; i++ )); do
		currentIndex=`expr $i + 1`
		currentProgress="${currentIndex}/${generateCount}"
		log "开始第 ${currentProgress} 视频的 随机资源选取"

		mergeAudiosFilePath=$todayOutputTempDir/$outputFilePrefix-audio-$currentIndex.txt
		mergeVideosFilePath=$todayOutputTempDir/$outputFilePrefix-video-$currentIndex.txt
		mergedAudiosFilePath=$todayOutputTempDir/$outputFilePrefix-$currentIndex.m4a
		mergedVideosFilePath=$todayOutputTempDir/$outputFilePrefix-$currentIndex.mp4
		outputVideoFilePathTemp=$todayOutputTempDir/$outputFilePrefix-$currentIndex-temp.mp4
		outputVideoFilePath=$todayOutputDir/$outputFilePrefix-$currentIndex.mp4

		# 记录所有音视频索引防止重复
		usedAudioFileIndexs=()
		usedVideoFileIndexs=()

		# 记录音视频时长
		audiosDuration=0
		videosDuration=0

		# 随机分配音频资源
		log "第${currentProgress}视频: 开始音频选取"
		randomAudioIndex=0
		while [[ $audiosDuration -lt $randomGenerateDuration ]]; do
			randomAudioValue=0
			if [[ $randomAudioIndex -eq 0 ]]; then
				randomAudioValue=${firstAudioIndexs[$i]}
			else 
				randomAudioFinished=0
				while [[ $randomAudioFinished -eq 0 ]]; do
					randomAudioValue=$[$RANDOM%$audiosFileCount]
					if [[ ! " ${usedAudioFileIndexs[@]} " =~ " ${randomAudioValue} " ]]; then
						# log "音频未包含 ${randomAudioIndex}则添加"
						randomAudioFinished=1
					else
						# log "音频包含 ${randomAudioIndex}"
						randomAudioFinished=0
					fi
				done
			fi
			usedAudioFileIndexs[$randomAudioIndex]=$randomAudioValue
			audioPathTemp=${audiosFilePath[randomAudioValue]}

			audioFileTempDir=${audioPathTemp%/*}
			audioFileTempName=$(basename "$audioPathTemp")
			audioFileTempExtension=${audioFileTempName##*.}
			audioFileTempName="${audioFileTempName%.*}"
			if [[ ! ($audioFileTempExtension = 'm4a' || $audioFileTempExtension = 'M4A') ]]; then
			# 	# 什么都不需要处理
			# else 
				newAudioFilePathTemp=$audioFileTempDir/$audioFileTempName.m4a
				ffmpeg -i $audioPathTemp -c:a aac -vn -y $newAudioFilePathTemp -hide_banner -loglevel $ffmpegLeve
				if [[ -e $newAudioFilePathTemp ]]; then
					rm $audioPathTemp
					audioPathTemp=$newAudioFilePathTemp
					audiosFilePath[randomAudioValue]=$audioPathTemp
				fi
			fi

			# 记录到文件
			$(writeFilesToPath $audioPathTemp $mergeAudiosFilePath)
			
			
			audioDuration=$( getFileDuration $audioPathTemp )
			audiosDuration=$(( $audiosDuration + $audioDuration ))
			audioDurationStr="$(( $audioDuration / 60 )):$(( $audioDuration % 60 ))"
			audiosDurationStr="$(( $audiosDuration / 3600 )):$(( $audiosDuration % 3600 / 60 )):$(( $audiosDuration % 60 ))"

			audioName=$(basename "$audioPathTemp")
			randomAudioIndex=`expr $randomAudioIndex + 1`
			log "第${currentProgress}视频: 选取了第${randomAudioIndex}个音频:${audioName} 时长:${audioDurationStr}s 总时长:${audiosDurationStr}"
		done
		log "第${currentProgress}视频: 开始视频选取"
		# 随机分配视频资源
		randomVideoIndex=0
		while [[ $videosDuration -lt $randomGenerateDuration ]]; do
			randomVideoValue=0
			if [[ $randomVideoIndex -eq 0 ]]; then
				randomVideoValue=${firstVideoIndexs[$i]}
			else
				randomVideoFinished=0
				while [[ $randomVideoFinished -eq 0 ]]; do
					usedVideoFileCount=${#usedVideoFileIndexs[@]}
					randomVideoValue=$[$RANDOM%$videosFileCount]
					# 如果记录的个数已经到达视频总个数，则随机生成重复使用。
					if [[ $usedVideoFileCount == videosFileCount ]]; then
						randomVideoFinished=1
					else
						if [[ ! " ${usedVideoFileIndexs[@]} " =~ " ${randomVideoValue} " ]]; then
							# log "音频未包含 ${randomAudioIndex}则添加"
							randomVideoFinished=1
						else
							# log "音频包含 ${randomAudioIndex}"
							randomVideoFinished=0
						fi
					fi
				done
			fi
			usedVideoFileIndexs[$randomVideoIndex]=$randomVideoValue
			videoPathTemp=${videosFilePath[randomVideoValue]}
			
			writeFilesToPath $videoPathTemp $mergeVideosFilePath
			
			videoDuration=$(getFileDuration $videoPathTemp)
			videosDuration=`expr $videoDuration + $videosDuration`
			videoDurationStr="$(( $videoDuration / 60 )):$(( $videoDuration % 60 ))"
			videosDurationStr="$(( $videosDuration / 3600 )):$(( $videosDuration % 3600 / 60 )):$(( $videosDuration % 60 ))"

			videoName=$(basename "$videoPathTemp")
			randomVideoIndex=`expr $randomVideoIndex + 1`

			log "第${currentProgress}视频: 选取了第${randomVideoIndex}个视频:${videoName} 时长:${videoDurationStr}s 总时长:${videosDurationStr}"
		done

		log "第 ${currentProgress} 视频：完成随机选取音视频"

		log "第 ${currentProgress} 视频：开始合成音频, 可能会比较耗时，请耐心等待..."
		mergeAVFiles $mergeAudiosFilePath $mergedAudiosFilePath

		log "第 ${currentProgress} 视频：开始合成视频, 可能会比较耗时，请耐心等待..."
		mergeAVFiles $mergeVideosFilePath $mergedVideosFilePath

		log "第 ${currentProgress} 视频：开始合并音视频, 可能会比较耗时，请耐心等待..."
		($rootDir/tools/merge_audio_video.sh $mergedAudiosFilePath $mergedVideosFilePath $outputVideoFilePathTemp)

		mv $outputVideoFilePathTemp $outputVideoFilePath

		log "第 ${currentProgress} 视频：移除产生的临时文件"
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
	done

	log "随机生成完了所有视频，可能存在部分视频失败或有问题，麻烦一个个视频简单查验下^_^"
	log "导出视频的目录: ${todayOutputDir}"
	log "如果生成的视频已经使用，可以删除当前文件夹^_^ ${todayOutputDir}"
	open ${todayOutputDir}
}

setupLog
randomGenerate $@


