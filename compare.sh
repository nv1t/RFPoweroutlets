#!/bin/bash
# usage: compare.sh "1-A-0" "1-A-1"

PLOT="set terminal png; set output '${1}.${2}.png'; unset key; set xr [0:0.031]; set yr [ 0:-0.2 ]; plot ";
for i in daten/${1}/*.wav;
do
	PLOT="${PLOT}'${i}.normalized' lt 3 pt 1,"; 
done;

for i in daten/${2}/*.wav;
do
        PLOT="${PLOT}'${i}.normalized' using 1:(\$2-0.005) lt 3 pt 1,";
done;

echo -e ${PLOT%?} | gnuplot
#rm daten/${1}/*.normalized
