#!/bin/sh
#usage: wav2png.sh file.wav


BASE=${1%.wav}
PNG=$BASE.png
WAV=$BASE.wav
DAT=$BASE.dat

#echo $BASE,$PNG,$WAV,$DAT
sox $WAV $DAT
grep -v '^;' $DAT >$DAT.clean
FREQ=`head -1 $DAT|tr -d ';'`

echo -e "set terminal png;set title '$FREQ';set output '$PNG'; set yr [-0.01:0.01];set xr [0:1]; plot '$DAT.clean' with lines" |gnuplot
rm $DAT $DAT.clean
