#!/bin/bash

(./arg_check.sh $@)
lastShellStatus=$?
if [[ $lastShellStatus -ne 0 ]]; then
	exit -1;
fi

copyjpgpath=$1;
directory=$2;

for i in $(ls $directory/*.mp3); do 
	index=$(basename ${i} .mp3); 
	imgpath=$directory/$index.jpg;
	cp -r $copyjpgpath $imgpath
done