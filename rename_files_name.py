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
			print filename, " -> ", newfilename
			os.rename(oldPath, newPath)
	
argCount = len(sys.argv)
for arg in xrange(1,argCount):
	# print 
	rename_filenames(sys.argv[arg])

