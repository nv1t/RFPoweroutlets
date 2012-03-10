#!/bin/bash
rm "${1}.png"
PLOT="set terminal png; set output '${1}.png'; unset key; set xr [-0.001:0.032]; set yr [ 0:-1.0 ]; plot ";
COUNTER=0
for i in daten/${1}/*.normalized;
do
	PLOT="${PLOT}'${i}' using 1:(\$2-0.005*${COUNTER}) lt 3 pt 3 ,";
	COUNTER=$(($COUNTER+1))
done;

echo -e ${PLOT%?} | gnuplot
