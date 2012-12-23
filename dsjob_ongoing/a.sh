#!/bin/ksh

. `dirname $0`/env.sh

trap '
echo $$ exiting ...
exit
' USR1

if [ $# -ne 2 ]; then
  echo
  echo "Usage: $0 project_name table_name"
  echo
  exit
fi

### function runftp {{{
function runftp {
  # add treats table prefix string
  if [ $istts -eq 1 ]; then
    ttsstr=tts
  else
    ttsstr=""
  fi
  # ongoing type data files are distinct from others data files.
  # (day1/ondate1/ondate2)
  case $type in
  ongoing) dest=data_${ttsstr}ongoing ;;
  day1)    dest=data_${ttsstr}day1 ;;
  date2)   dest=data_${ttsstr}ondate ;;
  date)    dest=data_${ttsstr}ondate ;;
  esac
  echo "===" >>$rootdir/log/ftp.log
  ftp -vin >>$rootdir/log/ftp.log 2>&1 <<EOF
open $sybhost
user $sybuser $sybpass
bin
lcd $dir
cd /sybiq/script/$dest
put $datafile
bye
EOF
}
# }}}

### function ftplogs {{{
function ftplogs {
  ftp -vin >>$rootdir/log/ftp.log 2>&1 <<EOF
open $monhost
user $monuser $monpass
bin
lcd $rootdir/log/$datedt
cd /dsjob
mkdir $datedt
cd $datedt
put ${log##*/}
put ${logsumm##*/}
bye
EOF
}
# }}}

### function getjobname {{{
function gettypename {
  if [ $istts -eq 1 ]; then
    etctype=tts
  else
    etctype=hub
  fi
  grep -l "^$tn\$" $rootdir/etc/${etctype}*.lst |read f3
  f3=${f3#*4}
  f3=${f3%.*}
  echo $f3
}
# }}}

### function getlibname {{{
function getlibname {
  if [ $istts -eq 1 ]; then
    etctype=TTS
  else
    etctype=HUB
  fi
  grep -l "^$tn\$" $rootdir/etc/*${etctype}*_SA |read f4
  if [ "x$f4" == "x" ]; then
    if [ $istts -eq 1 ]; then
      cat $rootdir/etc/ttslibname.txt |grep "^$tn " |read f41 f42
      echo $f42
    else
      echo AOCHUBFP
    fi
  else
    echo ${f4##*/}
  fi
}
# }}}

## function getlastbatch {{{
function getlastbatch {
  # get last batch TMZ
  db2 "select zatmze from oracle0928.ssjgavp where zajgid = 'SSSS999'" |\
    head -4 |tail -1
}
#}}}

###
### main
###

proj=$1
tn=$2

case $proj in
dpr_orc_prd)
  istts=0
  type=day1
  echo djpEXTday1$tn.$inst |sed 's/[#@]/_/g' |read job
  lib=$image
  fn=$tn
;;
dpr_orc_prd1)
  istts=1
  type=day1
  echo djpEXTday1$tn.$inst |sed 's/[#@]/_/g' |read job
  lib=$image
  fn=$tn
;;
dpr_orc_prd2)
  istts=0
  gettypename |read type
  echo djpEXT$type$tn |sed 's/[#@]/_/g' |read job
  getlibname |read lib
  fn=$tn
;;
dpr_orc_prd3)
  istts=1
  gettypename |read type
  echo djpEXT$type$tn |sed 's/[#@]/_/g' |read job
  getlibname |read lib
  fn=$tn
;;
*)
  echo "datastage project name not exist"
  exit
;;
esac

date +%Y%m%d%H%M%S\ %Y%m%d |read datets datedt
mkdir $rootdir/log/$datedt 2>/dev/null
log=$rootdir/log/$datedt/$job.$datets.log
logsumm=$rootdir/log/$datedt/job_status_$datedt.log

# timestamp
date +%Y%m%d%H%M\ %Y-%m-%d\ %H:%M:%S.000000 |read date ts

dsjob -jobinfo $proj $job >/dev/null 2>&1
if [ $? -eq 255 ]; then
  echo "job: $job not be found"
  exit
fi
dsjob -jobinfo $proj $job 2>/dev/null |awk -F'[()]' '/Job Status/{print $2}' |read status
if [ $status -eq 21 -o $status -eq 3 ]; then
 dsjob -run -mode RESET $proj $job >/dev/null 2>&1
fi

dsjob -lognewest $proj $job 2>/dev/null |awk -F'= ' '/Newest id/ {print $2}' |read first

# connect to db2
export DB2CODEPAGE=1208
. /home/sds01pc/sds01pc1/sqllib/db2profile
db2 connect to C6SYSTEM user $db2user using $db2pass >/dev/null

# get tddt lpdt
if [ $istts -eq 1 ]; then
  db2 "select XSLPDT,XSTDDT from oracle0928.ssdatep " |\
    head -4 |tail -1 |read lpdt tddt
else
  db2 "select XSLPDT,XSTDDT from oracle0928.ssdatep where XSMDFL = 'P' " |\
    head -4 |tail -1 |read lpdt tddt
fi
echo $lpdt |sed 's/[ .]//g' |read lpdt
echo $tddt |sed 's/[ .]//g' |read tddt
# if get lpdt error
cat $lpdt |grep -q "SQL"
if [ $? -eq 0 ]; then
  echo "get lpdt error"
  echo "lpdt: $lpdt"
  exit 9
else
  echo $lpdt |sed 's/\(....\)\(..\)\(..\)/\1-\2-\3/' |read lpdt
fi

case $type in
day1)
  # get image tmz as ts

  # start dsjob
  datafile=$fn.$datets$inst.TXT
  dsjob -run -warn 0 -wait -param prmFilTarget=$datafile -param prmDirTarget=$dir \
    -param prmUsrDB2=$db2user -param prmPwdDB2=$db2pass -param prmLibDB2=$lib \
    -param prmDteTimestamp="$ts" $proj $job 2>/dev/null
;;
ongoing) 
  # date format: cdc context   20080101T000000.000000000000
  # date format: cdc timestamp 2008-08-11T16:28:31.641408
  # date format: db2 TMZ       2008-08-11-16.28.31.641408

  . /sysp/attun51/cnorc/navroot/bin/nav_login.sh
  ts="2008-10-30 00:00:00.000000"

  # start dsjob
  datafile=$fn.`date +%y%m%d%H%M%S`.TXT
  dsjob -run -warn 0 -wait -param prmFilTarget=$datafile -param prmDirTarget=$dir \
    -param prmLibDB2=$lib -param prmDteTimestamp="$ts" \
    -param prmDteBegin="20080101T000000.000000000000" -param prmDteEnd="20081101T000000.000000000000" \
    $proj $job 2>/dev/null
;;
date2)
  # date format: 20080101

  getlastbatch |read currentlastbatch
  tail -1 $rootdir/savedata/lastbatch |read lastlastbatch
  if [ "$currentlastbatch" <= "$lastlastbatch" ]; then
    # batch is running
    exit 9
  fi

  if [ "$tddt" != `date +%Y%m%d` ]; then
    # today is holiday
    exit 9
  fi

  ts="$lpdt 00:00:00.000000"

  # start dsjob
  datafile=$fn.$datets.TXT
  dsjob -run -warn 0 -wait -param prmFilTarget=$datafile -param prmDirTarget=$dir \
    -param prmLibDB2=$lib -param prmUsrDB2=$db2user -param prmPwdDB2=$db2pass \
    -param prmDteBegin="$lpdt" -param prmDteTimestamp="$ts" \
    $proj $job 2>/dev/null
;;
date)
  ts="$lpdt 00:00:00.000000"

  # start dsjob
  datafile=$fn.$datets.TXT
  dsjob -run -warn 0 -wait -param prmFilTarget=$datafile -param prmDirTarget=$dir \
    -param prmLibDB2=$lib -param prmUsrDB2=$db2user -param prmPwdDB2=$db2pass \
    -param prmDteTimestamp="$ts" \
    $proj $job 2>/dev/null
;;
esac

dsjob -lognewest $proj $job 2>/dev/null |awk -F'=' '/Newest id/ {print $2}' |read last
dsjob -logsum -max $((last-first)) $proj $job 2>/dev/null >$log

dsjob -jobinfo $proj $job 2>/dev/null |awk -F'[()]' '/Job Status/{print $2}' |read result

#ssh $sftpuser@$monhost mkdir /cygdrive/d/Hsbc_Project_Oracle/dsjob/$datedt/ >/dev/null 2>&1 &

cat $log |grep "records exported successfully" |awk '{print $4" "$8}' |read rowsucc rowfail
$rootdir/logchk.sh $log |xargs |read fatalwarntype

case $result in
1|2)  # RUN OK (1) / RUN WITH WARNING (2)
  case $result in
  1)
    echo "$image,$tn,SUCC($fatalwarntype),$log,$rowsucc,$rowfail"
    echo "$image,$tn,SUCC($fatalwarntype),$log" >>$logsumm
  ;;
  2)
    echo "$image,$tn,WARN($fatalwarntype),$log,$rowsucc,$rowfail"
    echo "$image,$tn,WARN($fatalwarntype),$log" >>$logsumm
  ;;
  esac
  ftplogs
  ls -l $dir/$datafile |awk '{print $5}' |read sz
  if [ $sz -gt 0 ]; then
    runftp
    if [ $type == "ongoing" ]; then
      echo "$tn $currentcontext" >> $rootdir/savedata/lastcontext
    fi
  fi
;;
3)  # RUN FAILED (3)
  echo "$image,$tn,FAIL($fatalwarntype),$log"
  echo "$image,$tn,FAIL($fatalwarntype),$log" >>$logsumm
  ftplogs
  dsjob -run -mode RESET $proj $job >/dev/null 2>&1
;;
21) # RESET (21)
  echo "$image,$tn,need RESET,$log"
  echo "$image,$tn,need RESET,$log" >>$logsumm
  ftplogs
  dsjob -run -mode RESET $proj $job >/dev/null 2>&1
;;
99) # NOT RUNNING (99) <compiled>
  :
;;
esac

db2 disconnect C6SYSTEM >/dev/null

exit

# vim:foldmethod=marker:foldenable:foldlevel=0

