#!/usr/bin/python

# USAGE:
# expects cleaned sox output on stdin: awk '! ($0 ~ /;/) { print $1 " " $2 }' "soxoutput.dat" | python cleanSignal.py


import fileinput
import sys

PauseLength = 0.009 # Pause Length between two Signals. Everything above will considered as a pause
SignalLength = 0.03 # Signallength, everything above will be considered a signal
Threshold = 0.0 # what should be logged if you have some kind of ground noise
Precision=4 # Measuring is done with 192kHz. Precision rounds ;)


# ---------------------------------------------------------------------
start = [0.0,0.0]
last = [0.0,0.0]
signals = []
signalbuff = []
normalizeTime = 0.0
inSignal=False

# Isolating the signals with a length of SignalLength from the sox output 
for line in fileinput.input():
	current = [float(i) for i in line.rstrip().split(" ")]
	if start[1] != current[1]:
		duration = current[0] - start[0]
		if duration >= PauseLength and start[1] == 0.0:	
			# a pause started, therefore save the last signal 
			# and set SignalFlag
			signals.append(signalbuff)
			signalbuff = []
			inSignal=False
		start=current

	# Checks if a signal starts and logs the time for normalization
	if current[1] < 0.0 and not inSignal: 
		normalizeTime = current[0]
		inSignal=True

	# logs spikes which are smaller than threshold.
	# in my 
	if inSignal and current[1] < Threshold: 
		signalbuff.append([round(current[0]-normalizeTime,Precision),current[1],1])

signalbuff = []
signalbuff = signals.pop(0)

# runs through all signals and adds them up to one signal
for i in signals:
	if i[len(i)-1][0] >= SignalLength: # and i[len(i)-1][0] <= 0.031:
		for j in i:
			for k in range(len(signalbuff)):
				if signalbuff[k][0] == j[0]:
					signalbuff[k][1] += j[1]
					signalbuff[k][2] += 1
					break

				if signalbuff[k][0] > j[0]:
					signalbuff.insert(k,[j[0],j[1],1])
					break

			if signalbuff[len(signalbuff)-1][0] < j[0]:
					signalbuff.append([j[0],j[1],1]);


for i in signalbuff:
	print(str(i[0])+' '+str(i[1]/i[2])+' '+str(i[1])+' '+str(i[2]))
