#!/usr/bin/ksh

if [ $# -ne 2 ];then
 echo "Uasge: $0 <day1|ongoing> date "
 exit 9
fi

type=$1
datestr=$2
basedir=/sybiq/script

case $type in 
day1)
   datadir='
done_day1
done_ttsday1
'
;;
ongoing)
   datadir='
done_ongoing
done_ttsongoing
done_ondate
done_ttsondate
'
;;
*)
   echo "Input Error Type"
   exit 9
;;
esac

>$basedir/${type}.${datestr}.sum

for i in $datadir;do
 cd $basedir/$i
 for sz in *.${datestr}*.orig;do
   ls -l $sz
 done |awk '{print $5}' >>$basedir/${type}.${datestr}.sum
done

