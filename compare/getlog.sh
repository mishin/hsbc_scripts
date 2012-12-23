#!/usr/bin/ksh

if [  $# -ne 3 ] && [ $# -ne 2 ];then
 echo "Usage:  $0 <ttsday1|day1|ongoing> <ds|load> [date] "
 exit 0
fi

SSH="/usr/bin/ssh"
sshstr="-p 22 orcftp1@130.37.65.11"
SCP="/usr/bin/scp"
scpstr="-P 22 orcftp1@130.37.65.11"

type=$1
islocal=$2
datestr=$3
localdir=/sybiq/script

if [ "X$datestr" == "X" ];then
  datestr=`date +%Y%m%d`
fi

case $type in 
ttsday1)
 if [ $islocal == "ds" ];then  
   $SCP -r $scpstr:dsjob/log/dslog/*tts*.${datestr}*.dslog . 2>/dev/null || \
     echo "get remote dslog error !"
   $SCP -r $scpstr:dsjob/list/$datestr/tts*.0e.rows . 2>/dev/null || \
     echo "get remote db2log error !"
 elif [ $islocal == "load" ];then
   ls $localdir/day1log/data_ttsday1.${datestr}*.loadlog >/dev/null 2>/dev/null && \
     cp $localdir/day1log/data_ttsday1.${datestr}*.loadlog  .

   # Calculate ttsday1 size
   sumSize=0
   ls $localdir/day1log/data_ttsday1.${datestr}*.dslst >/dev/null 2>/dev/null && \
     cat $localdir/day1log/data_ttsday1.${datestr}*.dslst |awk '{print $1}'| \
       	while read size;do
	 sumSize=$((sumSize+size))
	done	  
   echo "scale=2 ; $sumSize/1024/1024" |bc |read totalSize
   echo "`date +"%Y-%m-%d.%H:%M:%S"`  \t$type \t$totalSize(MB)" >> ./totalsize 
   tail -1 ./totalsize
 else
   echo "Illegal $islocal"
   exit 9
 fi
   ;;   
day1)
 if [ $islocal == "ds" ];then  
   $SCP -r $scpstr:dsjob/log/dslog/*hub*.${datestr}*.dslog . 2>/dev/null || \
     echo "get remote dslog error !"
   $SCP -r $scpstr:dsjob/list/$datestr/hub*.0e.rows . 2>/dev/null  || \
     echo "get remote db2log error !"
 elif [ $islocal == "load" ];then
   ls $localdir/day1log/data_day1.${datestr}*.loadlog >/dev/null 2>/dev/null && \
     cp $localdir/day1log/data_day1.${datestr}*.loadlog  .

   # Calculate day1 size
   sumSize=0
   ls $localdir/day1log/data_day1.${datestr}*.dslst >/dev/null 2>/dev/null && \
     cat $localdir/day1log/data_day1.${datestr}*.dslst|awk '{print $1}'| \
     while read size;do
	sumSize=$((sumSize+size))
     done
   echo "scale=2 ; $sumSize/1024/1024" |bc |read totalSize
   echo "`date +"%Y-%m-%d.%H:%M:%S"`  \t$type \t$totalSize(MB)" >> ./totalsize
   tail -1 ./totalsize
 else
   echo "Illegal $islocal"
   exit 9

 fi
   ;;
ongoing)
   #Get remote dslog
 if [ $islocal == "ds" ];then  
   $SCP -r $scpstr:dsjob_ongoing/log/dslog/*.${datestr}*.dslog . 2>/dev/null || \
      echo "get remote dslog error ! "
 elif [ $islocal == "load" ];then
   ###############
   #
   # Get local loadlog
   #
   ###############

   sumSize=0

   # get data_ongoing loadlog and size
   ls $localdir/ongoinglog/data_ongoing.${datestr}*.loadlog >/dev/null 2>/dev/null && \
      cat $localdir/ongoinglog/data_ongoing.${datestr}*.loadlog >allongoing.${datestr}.loadlog

   ls $localdir/ongoinglog/data_ongoing.${datestr}*.dslst >/dev/null 2>/dev/null && \
      cat $localdir/ongoinglog/data_ongoing.${datestr}*.dslst|awk '{print $1}'| \
        while read size ;do
          sumSize=$((sumSize+size))
        done

   # get data_ttsongoing loadlog and size
   ls $localdir/ongoinglog/data_ttsongoing.${datestr}*.loadlog >/dev/null 2>/dev/null && \
      cat $localdir/ongoinglog/data_ttsongoing.${datestr}*.loadlog >>allongoing.${datestr}.loadlog
   ls $localdir/ongoinglog/data_ttsongoing.${datestr}*.dslst >/dev/null 2>/dev/null && \
      cat $localdir/ongoinglog/data_ttsongoing.${datestr}*.dslst |awk '{print $1}' |\
        while read size;do
          sumSize=$((sumSize+size))
        done


   # get data_ondate loadlog and size
   ls $localdir/ongoinglog/data_ondate.${datestr}*.loadlog >/dev/null 2>/dev/null && \
      cat $localdir/ongoinglog/data_ondate.${datestr}*.loadlog  >>allongoing.${datestr}.loadlog
   ls $localdir/ongoinglog/data_ondate.${datestr}*.dslst >/dev/null 2>/dev/null && \
      cat $localdir/ongoinglog/data_ondate.${datestr}*.dslst |awk '{print $1}' |\
	while read size;do
	  sumSize=$((sumSize+size))
        done


   # get data_ttsondate loadlog and size
   ls $localdir/ongoinglog/data_ttsondate.${datestr}*.loadlog >/dev/null 2>/dev/null && \
      cat $localdir/ongoinglog/data_ttsondate.${datestr}*.loadlog  >>allongoing.${datestr}.loadlog
   ls $localdir/ongoinglog/data_ttsondate.${datestr}*.dslst >/dev/null 2>/dev/null && \
      cat $localdir/ongoinglog/data_ttsondate.${datestr}*.dslst |awk '{print $1}' |\
	while read size;do
	  sumSize=$((sumSize+size))
	done
 	
   # Return the total size(MB)
   echo "scale=2 ; $sumSize/1024/1024" |bc  |read totalSize
   echo "`date +"%Y-%m-%d.%H:%M:%S"`  \t$type \t$totalSize(MB)" >> ./totalsize
   tail -1 ./totalsize

 fi
   ;;
*)
   echo "Input Error Type"
   exit 9
esac
