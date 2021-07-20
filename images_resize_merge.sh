#!/bin/bash

(./arg_check.sh $@)
lastShellStatus=$?
if [[ $lastShellStatus -ne 0 ]]; then
	exit -1;
fi

tempDir=$1/temp
mkdir tempDir
echo 'start remove temp images.'
rm $tempDir/resize_*.[jJ][pP][gG]
echo 'end remove temp images.'
imageList=$(ls $1/*.[jJ][pP][gG])
for i in $imageList; do
	fileName=$(basename ${i})
	directory=$tempDir;
	newName=resize_$fileName;
	echo "start generate image $fileName to $newName"
	convert $i -resize 1280x720! $directory/$newName;
done
echo 'convert images finished!!!!'

outputDir=$1/output
mkdir $outputDir
imageList=$(ls $tempDir/resize_*.[jJ][pP][gG])
radio=25
convert -gravity center $tempDir/resize_*.jpg -crop $radio%x100% +append $outputDir/all.jpg

