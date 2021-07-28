#!/bin/bash

function generatevideo() {
	path=$1
	lastDirName=${path##*/}
	logFilePath="${path}/${lastDirName}_log.txt"
	printf "${lastDirName} start $(date)\n" >> $logFilePath; 

	echo "****** start ${path} ******"
	(./format_to_mp3.sh $path)
	lastShellStatus=$?
	if [[ $lastShellStatus -ne 0 ]]; then
		return;
	fi

	(./format_to_mp4.sh $path)
	lastShellStatus=$?
	if [[ $lastShellStatus -ne 0 ]]; then
		return;
	fi

	(./merge_videos.sh $path)
	lastShellStatus=$?
	if [[ $lastShellStatus -ne 0 ]]; then
		return;
	fi
	(./merge_audios.sh $path)
	lastShellStatus=$?
	if [[ $lastShellStatus -ne 0 ]]; then
		return;	
	fi

	(./merge_mp4_mp3.sh $path)
	lastShellStatus=$?
	if [[ $lastShellStatus -ne 0 ]]; then
		return;	
	fi
	echo "****** finished ${path} ******"
	printf "${lastDirName} end $(date)\n" >> $logFilePath; 
}

(./arg_check.sh $@)

lastShellStatus=$?
if [[ $lastShellStatus -ne 0 ]]; then
	exit -1;
fi

for arg in $@; do
	generatevideo $arg
done