#!/bin/bash

argsCount=($# -ge 1)

if [[ $argsCount == 0 ]]; then
	echo "Please input file directory..."
    exit -1
fi