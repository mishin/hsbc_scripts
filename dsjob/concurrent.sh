#!/usr/bin/ksh

. `dirname $0`/env.sh

datestamp=`date +"%Y%m%d%H%M%S"`

if [[ $# -ne 0 && $# -ne 1 ]];then
  echo "$0 [jobs.lst]"
  exit 9
fi

joblist=$1

if [ "X$joblist" == "X" ];then
  joblist=jobs.lst
fi

if [[ ! -f $rootdir/$joblist ]];then
  echo "$joblist is not exist"
  exit 9
fi
  
# Redirect standard output and standard error to log file
OUT=${rootdir}/log/dslog/${joblist%%.*}.${datestamp}.dslog
exec 1>> ${OUT} 2>&1
chmod 666 ${OUT}

# get shadow cutoff time
# date format: tmz 2007-09-14-09.40.12.516000
export DB2CODEPAGE=1208
. /home/sds01pc/sds01pc1/sqllib/db2profile
db2 connect to C6SYSTEM user $db2user using $db2pass >/dev/null
db2 "select zatmze from aochubfp.ssjbavp where zajbnm = 'SSSHWCUTOF' " |\
  head -4 |tail -1 |read shwcutof
# if shwcutof lower than last shwcutof , then exit
export shwcutof

cat $rootdir/maxjobs |read max
pid=$rootdir/pid
>$pid

trap '
echo i am exiting ...
kill -USR1 `cat $rootdir/pid |xargs`
EXIT=1
' INT TERM

EXIT=0
cat $rootdir/$joblist |while read project name ; do
  cat $pid |wc -l |read curr
  cat $rootdir/maxjobs |read max
  if [ $curr -ge $max ]; then
    while true ; do
      if [ $EXIT -eq 1 ]; then
        break 99
      fi
      cat $pid |while read p ; do
        ps -p $p >/dev/null
        if [ $? -eq 1 ]; then
          cat $pid |grep -vw $p > $$
          mv -f $$ $pid
          break 2
        fi
        #cat $pid |xargs
      done
      sleep 2
    done
  fi
  $rootdir/dsjob_sche.sh $project $name &
  sleep 1
  echo $! >>$pid
done

wait

if [ $EXIT -eq 0 ];then
  df -Pk /hsbc/orc/data |tail -1 |awk '{print$5}'|tr -d '%'|read currSpace
  if [ $currSpace -lt 98 ];then
    cat $rootdir/$joblist | grep -qw "dpr_orc_prd" && >$dir/data_day1.day1flag
    cat $rootdir/$joblist | grep -qw "dpr_orc_prd1" && >$dir/data_ttsday1.day1flag
  else
    echo "Current Capacity space=$currSpace % "
    exit  
  fi
fi

rm -f $pid
