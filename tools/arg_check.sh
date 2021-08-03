#!/bin/bash

source $(dirname "$0")/tool.sh

argsCount=($# -ge 1)

if [[ $argsCount == 0 ]]; then
	error "Please input file directory..."
fi