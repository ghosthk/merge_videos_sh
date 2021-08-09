#!/usr/bin/python
# -*- coding: UTF-8 -*-

import sys
import os

def rename_filenames(path):
	filenames = os.listdir(path)
	for filename in filenames:
		if " " in filename:
			newfilename = filename.replace(' ', '-')
			oldPath = os.path.join(path, filename)
			newPath = os.path.join(path, newfilename)
			print("{} -> {}".format(filename, newfilename))
			os.rename(oldPath, newPath)

if __name__ == '__main__':
	try:
	    # Python 2
	    xrange
	except NameError:
	    # Python 3, xrange is now named range
	    xrange = range
	argCount = len(sys.argv)
	print("***** 进行文件名校验，一共{}个文件夹 ********".format(argCount-1))
	for arg in xrange(1, argCount):
		filepath=sys.argv[arg]
		print("***** 开始第({}/{}) {} 文件名校验 ********".format(arg, argCount-1, filepath))
		rename_filenames(filepath)
	print("***** 完成文件名校验 ********")


