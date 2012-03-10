#!/bin/bash
COUNTER=0
for i in daten/${1}/*.wav;
do
	if [ ! -e "${i}.normalized" ]; then
		./cleanSignal.sh "${i}";
	fi;
done;
