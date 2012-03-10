#!/usr/bin/python2

import sys

f = open(sys.argv[1])


start = [0.0,0.0]
for l in f.read().split("\r\n"):
	if l and not l[0] == ';':
		current = map(lambda t: float(t), filter(lambda x: not x == '', l.split(" ")))
		if start[1] != current[1]:
			duration = current[0] - start[0]
			print ' '.join([str(i) for i in [start[0],current[0],duration,start[1]]])
			start = current 

			if 
print ' '.join([str(i) for i in [start[0],current[0],current[0]-start[0],start[1]]])
