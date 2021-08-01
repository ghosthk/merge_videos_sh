#!/bin/bash

function warning() {
	echo "****************有警告啦********************" 1>&2
	echo "警告信息: $*"
}

function error() {
	echo "****************有错误啦********************" 1>&2
	echo "错误信息: $*"
	exit 1
}

function log() {
	echo "$*"
}
