#!/bin/bash
file=$1
origfile=${file}.orig
if [ "X$file" == "X" ];then
	echo "Usage:`basename $0` listfile"
	exit 9
fi

mv -f $file $origfile && \
cat $origfile |grep -v -e " BAIMTHP$" -e " BAOMTHP$" -e " IRDLIFP$" \
	-e " LP@OGHP$" -e " SSFXCSP$" -e " IE@TNJNP$" \
	>$file
