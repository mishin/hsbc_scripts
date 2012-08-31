#!/usr/bin/ksh
# summery the large table data
# sum.sh
# date : 2009-06-03
if [ $# -ne 1 ];then
	echo "Usage:`basename $0` loadlog"
 	exit 
fi
loadlog=$1
if [ ! -f $loadlog ];then
	echo "Illege file name:catn't find $loadlog"
	exit 9
fi
for i in 1 2 3 4 ;do
	cat $loadlog|grep "$i[0-9]\.TXT" |\
		awk '{sum+=$1}END{printf "%s\t%0.2f\t%s\n","hub",sum/1024/1024,"MB"}'
done

