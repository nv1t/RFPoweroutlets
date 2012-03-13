#!/bin/bash

usage()
{
cat << EOF
usage: $0 options

Makefile for Signal Processing. -c -p or -i is mandatory.
The plotting option has to be after an -i ;)
-a or -t have to be set.
verbose mode can be -vv -vvv ... verbosity is increasing

OPTIONS:
   -h      Show this message
   -i      create a normalized file
   -c      clean all script generated files
   -p      plot (only plots normalized files)
   -t	   target (shouldn't and can't be used with -a)
   -a      use -i, -c or -p on every directory in "data"
   -v      Verbose cat be clustered like "-vvvv" 
EOF
}

CLEAN=
VERBOSE=
CREATE=
TARGET=
PLOT=
while getopts “ht:aivcp” OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         c)
             CLEAN=1
             ;;
	 i)
	     CREATE=1
             ;;
         v)
             VERBOSE=$(($VERBOSE+1))
             ;;
	 t) 
             TARGET=$OPTARG
             ;;
	 a)
	     ALL=1
	     ;;
	 p)
	     PLOT=1
             ;;
         ?)
             usage
             exit 10
             ;;
     esac
done

if [[ -z $CLEAN ]] && [[ -z $CREATE ]] && [[ -z $PLOT ]]
then
     usage
     exit 1
fi

if [[ -z $TARGET ]] && [[ -z $ALL ]]
then
usage
exit 10
fi

verbose() {
	if [[ $VERBOSE ]] && [[ $VERBOSE -ge $2 ]]
	then
		echo "[${2}] ${1}"
	fi
}


if [[ $CLEAN ]]
then
	verbose "Cleaning Process started" 1
	if [[ $ALL ]] 
	then 
		verbose "deleting all script generated files" 2
		buff="data"
	else
		verbose "deleting script generated files in ${TARGET}" 2
		if [[ $TARGET ]]; then buff="data/${TARGET}"; fi;
	fi
	verbose "deleting PNG files" 3
	find ${buff} -name "*.png" -print0 | xargs -0 rm 2> /dev/null;
	verbose "deleting normalized files" 3
	find ${buff} -name "*.normalized" -print0 | xargs -0 rm 2> /dev/null;
	verbose "deleting dat files" 3
	find ${buff} -name "*.dat" -print0 | xargs -0 rm 2> /dev/null;
fi

if [[ $CREATE ]]
then
	if [[ $ALL ]]
	then
		verbose "Scanning through all directorys in data" 1
		for x in `find data -name '*.wav'`;
		do
			verbose "processing ${x}" 3
			verbose "generating sox..." 4
			sox "${x}" "${x}.dat"
			verbose "cleaning Signal..." 4
			awk '! ($0 ~ /;/) { print $1 " " $2 }' "${x}.dat" | python bin/cleanSignal.py > "${x}.normalized"
			verbose "removing sox file..." 4
			rm "${x}.dat"
		done
	else
		for x in `find data/${TARGET} -name '*.wav'`;
		do
			verbose "processing ${x}" 3
			verbose "generating sox..." 4
			sox "${x}" "${x}.dat"
			verbose "cleaning Signal..." 4
			awk '! ($0 ~ /;/) { print $1 " " $2 }' "${x}.dat" | python bin/cleanSignal.py > "${x}.normalized"
			verbose "removing sox file..." 4
			rm "${x}.dat"
		done;
	fi
fi

if [[ $PLOT ]]
then
	verbose "Plotting process started" 1
	if [[ $ALL ]]
	then
		for i in `find data -type d | sed '1d'`;
		do
			verbose "processing ${i}" 2
			name=$(echo $i | sed 's#/#.#g')
			verbose "generating gnuplot output" 3
			buff="set terminal png; set output '${name}.png'; unset key; set xr [-0.001:0.032]; set yr [ 0:-1.0 ]; plot ";
			COUNTER=0
			for x in ${i}/*.normalized;
			do 
				verbose "processing ${x}" 4
				buff="${buff}'${x}' using 1:(\$2-0.005*${COUNTER}) lt 3 pt 3 ,";
				COUNTER=$(($COUNTER+1));
			done;
			verbose "plotting with gnuplot" 3
			echo -e ${buff%?} | gnuplot 2> /dev/null
		done;
	else
		name=$TARGET
		verbose "processing ${name}" 2
		verbose "generating gnuplot output" 3
		buff="set terminal png; set output '${name}.png'; unset key; set xr [-0.001:0.032]; set yr [ 0:-1.0 ]; plot ";
		COUNTER=0
		for x in data/${name}/*.normalized;
		do
			verbose "processing ${x}" 4
			buff="${buff}'${x}' using 1:(\$2-0.005*${COUNTER}) lt 3 pt 3 ,";
			COUNTER=$(($COUNTER+1));
		done;
		verbose "plotting with gnuplot" 3
		echo -e ${buff%?} | gnuplot 2> /dev/null
	fi
fi
