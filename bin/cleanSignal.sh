#!/bin/bash

echo -n "Generating SOX..."
sox "${1}" "${1}.dat"
echo "DONE"
echo -n "Generating Signal..."
awk '! ($0 ~ /;/) { print $1 " " $2 }' "${1}.dat" | python cleanSignal.py > "${1}.normalized"
echo "DONE"
rm "${1}.dat"
