#!/bin/bash

I=0
PREFIX=$(date | sed 's/ //g;s/://g')
DEVICE="default:CARD=Device"

mkdir "daten/${1}" 2> /dev/null

while [ 1 ]; do
	read
	arecord -D "${DEVICE}" -t wav -r 192000 -d 1 > "daten/${1}/${PREFIX}.${I}.wav"
	echo $I "done"
	I=$(($I+1))
done;
