#!/bin/bash

downloadsDir=$HOME/Downloads

resourceDir=$downloadsDir/Resources
videosResouceDir=$resourceDir/videos
logDir=$downloadsDir/GH_log
separateVideoDir=$downloadsDir/GH_separateVideoDir
separateAudioDir=$downloadsDir/GH_separateAudioDir
clipVideoDir=$downloadsDir/GH_clipVideoDir
clipAudioDir=$downloadsDir/GH_clipAudioDir
outputDir=$downloadsDir/GH_output
todayOutputDir=$outputDir/$(date "+%Y%m%d")
todayOutputTempDir=$todayOutputDir/temp

videoWidth=1280
videoHeight=720

# 随机生成视频时长
randomGenerateDuration=3660
# 每次裁剪的时长 60s
everyClipDuration=60 

currentTime=$(date "+%Y%m%d%H%M%S")
logPath="${logDir}/${currentTime}.log"
ffmpegLogPath="${logDir}/${currentTime}_ff.log"
ffmpegLeve=8
FFREPORT=file=$ffmpegLogPath:level=$ffmpegLeve

export videosResouceDir
export separateVideoDir
export separateAudioDir
export clipVideoDir 
export clipAudioDir
export FFREPORT
export ffmpegLeve
export todayOutputDir
export randomGenerateDuration
export everyClipDuration

export videoWidth
export videoHeight

if [[ ! -d $resourceDir ]]; then
	mkdir $resourceDir
fi
if [[ ! -d $videosResouceDir ]]; then
	mkdir $videosResouceDir
fi
if [[ ! -d $logDir ]]; then
	mkdir $logDir
fi
if [[ ! -d $separateVideoDir ]]; then
	mkdir $separateVideoDir
fi
if [[ ! -d $separateAudioDir ]]; then
	mkdir $separateAudioDir
fi
if [[ ! -d $clipVideoDir ]]; then
	mkdir $clipVideoDir
fi
if [[ ! -d $clipAudioDir ]]; then
	mkdir $clipAudioDir
fi

exec >> $logPath

# ********************** log *******************
function warning() {
	echo "****************有警告啦********************"
	echo "警告信息: $1"
	echo "****************有警告啦********************" 1>&2
	echo "警告信息: $1" 1>&2
}

function error() {
	echo "****************有错误啦********************"
	echo "错误信息: $1"
	echo "****************有错误啦********************" 1>&2
	echo "错误信息: $1" 1>&2
	echo "运行记录文件地址: ${logPath}" 1>&2
	echo "FFMPEG记录地址: ${ffmpegLogPath}" 1>&2
	exit 1
}

function log() {
	echo "$1"
	echo "$1" 1>&2
}

# ********************** folder *******************
function makeOutputDir() {
	if [[ ! -d $outputDir ]]; then
		mkdir $outputDir
	fi
	if [[ ! -d $todayOutputDir ]]; then
		mkdir $todayOutputDir
	fi
	if [[ ! -d $todayOutputTempDir ]]; then
		mkdir $todayOutputTempDir
	fi
}

# ********************** FFMPEG *******************
function mergeAVFiles() {
	if [[ ! -e $1 ]]; then
		error "${1} 文件不存在, 请检查..."
	fi
	ffmpeg -f concat -safe 0 -i $1 -c copy -y $2 -hide_banner -loglevel $ffmpegLeve
}

function getFileDuration() {
	duration=$(ffmpeg -i $1 2>&1 | grep "Duration"| cut -d ' ' -f 4 | sed s/,// | sed 's@\..*@@g' | awk '{ split($1, A, ":"); split(A[3], B, "."); print 3600*A[1] + 60*A[2] + B[1] }')
	echo $duration
	return $duration
}

function writeFilesToPath() {
	printf "file '${1}'\n" >> $2; 
}