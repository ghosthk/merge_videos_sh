#!/bin/bash

source ./errorlog.sh

argsCount=($# -ge 1)

if [[ $argsCount == 0 ]]; then
	error "Please input file directory..."
fi