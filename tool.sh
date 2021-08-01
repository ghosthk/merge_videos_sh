#!/bin/bash

downloadsDir=$HOME/Downloads

logDir=$downloadsDir/GH_log
separateVideoDir=$downloadsDir/GH_separateVideoDir
separateAudioDir=$downloadsDir/GH_separateAudioDir
clipVideoDir=$downloadsDir/GH_clipVideoDir
clipAudioDir=$downloadsDir/GH_clipAudioDir

currentTime=$(date "+%Y%m%d%H%M%S")
logPath="${logDir}/${currentTime}.log"
ffmpegLogPath="${logDir}/${currentTime}_ff.log"
ffmpegLeve=8
FFREPORT=file=$ffmpegLogPath:level=$ffmpegLeve

export separateVideoDir
export separateAudioDir
export clipVideoDir 
export clipAudioDir
export FFREPORT
export ffmpegLeve

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