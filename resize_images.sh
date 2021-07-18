#!/bin/bash

(./arg_check.sh $@)
lastShellStatus=$?
if [[ $lastShellStatus -ne 0 ]]; then
	exit -1;
fi

echo 'start remove temp images.'
rm $1/temp_*.[jJ][pP][gG]
echo 'end remove temp images.'
imageList=$(ls $1/*.[jJ][pP][gG])
for i in $imageList; do
	fileName=$(basename ${i})
	directory=${i%/*};
	newName=temp_$fileName;
	echo "start generate image $fileName to $newName"
	convert $i -resize 1280x720! $directory/$newName;
done
echo 'convert images finished!!!!'