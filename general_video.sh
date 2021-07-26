#!/bin/bash

function generatevideo() {
	path=$1
	echo "****** start ${path} ******"
	(./resize_mp4.sh $path)
	lastShellStatus=$?
	if [[ $lastShellStatus -ne 0 ]]; then
		return;
	fi

	(./merge_videos.sh $path)
	lastShellStatus=$?
	if [[ $lastShellStatus -ne 0 ]]; then
		return;
	fi
	(./merge_mp3s.sh $path)
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
}

(./arg_check.sh $@)

lastShellStatus=$?
if [[ $lastShellStatus -ne 0 ]]; then
	exit -1;
fi

for arg in $@; do
	generatevideo $arg
done