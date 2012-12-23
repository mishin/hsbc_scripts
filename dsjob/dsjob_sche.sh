#!/bin/ksh

. `dirname $0`/env.sh

trap '
echo $$ exiting ...
exit
' USR1

if [ $# -ne 3 ]; then
  echo
  echo "Usage: $0 image project_name table_name"
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
  Ongoing) dest=data_${ttsstr}ongoing ;;
  Day1)    dest=data_${ttsstr}day1 ;;
  Date1)   dest=data_${ttsstr}ondate ;;
  Date2)   dest=data_${ttsstr}ondate ;;
  Date)    dest=data_${ttsstr}ondate ;;
  esac
  echo "===" >>$rootdir/log/ftp.log
  ftp -vin >>$rootdir/log/ftp.log 2>&1 <<EOF
open $sybhost
user $sybuser $sybpass
bin
lcd $datadir
cd /sybiq/script/$dest
put $datafile
bye
EOF
}
# }}}

### function touchfiles {{{
function touchfiles {
  if [ $istts -eq 1 ]; then
    ttsstr=tts
  else
    ttsstr=""
  fi
  touchfilesdir=$rootdir/../fetchfiles
  case $type in
  Ongoing) destdir=$touchfilesdir/${ttsstr}ongoing ;;
  Day1)    destdir=$touchfilesdir/${ttsstr}day1 ;;
  Date1)   destdir=$touchfilesdir/${ttsstr}ondate ;;
  Date2)   destdir=$touchfilesdir/${ttsstr}ondate ;;
  Date)    destdir=$touchfilesdir/${ttsstr}ondate ;;
  esac
  touch $destdir/$datafile
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

###
### main
###

image=$1
proj=$2
tn=$3
case $image in
oraclehub1|oracletts1)
    inst=1
;;
oraclehub2|oracletts2)
    inst=2
;;
oraclehub3|oracletts3)
    inst=3
;;
oraclehub4|oracletts4)
    inst=4
;;
*)
    echo "image not found"
    exit 9
;;
esac

# treats tables or not
case $proj in
dpr_orc_dev)
    istts=0
    grep -lw "^$tn" $rootdir/AOC_ORACLE_TEST*_SA |read lib
    lib=${lib##*/}
;;
dpr_orc_dev1)
    istts=0
    grep -lw "^$tn" $rootdir/AOC_ORACLE_TEST*_SA |read lib
    lib=${lib##*/}
;;
dpr_orc_dev2)
    istts=1
    export db2user=$ttsdb2user
    export db2pass=$ttsdb2pass
    grep -lw "$tn" $rootdir/AOC_ORACLE_TTS*_SA |read lib
    lib=${lib##*/}
;;
dpr_orc_prd)
    istts=0
    type=Day1
    echo djpEXTday1$tn.$inst |sed 's/[#@]/_/g' |read job
    lib=$image
    fn=$tn
;;
dpr_orc_prd1)
    istts=1
    type=Day1
    echo djpEXTday1$tn.$inst |sed 's/[#@]/_/g' |read job
    export db2user=$ttsdb2user
    export db2pass=$ttsdb2pass
    lib=$image
    fn=$tn
;;
dpr_orc_prd2)
    istts=0
    type=Day1
    echo djpEXTday1$tn |sed 's/[#@]/_/g' |read job
    lib=oraclehub1
    fn=$tn
;;
dpr_orc_prd3)
    istts=1
    type=${job%%_*}
    echo ${job#*_} |read fn
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

#cat $rootdir/sharpinfn |grep "^$fn "  |read sharp1 sharp2
#if [ "x" == "x$sharp2" ]; then
#  echo $fn |sed 's/_/@/' |read fn
#else
#  fn=$sharp2
#fi

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
db2 rollback >/dev/null
db2 connect to C6SYSTEM user $db2user using $db2pass >/dev/null

# get lpdt
if [ $istts -eq 1 ]; then
  db2 "select XSLPDT from $lib.ssdatep " |head -4 |tail -1 |\
    sed 's/[ .]//g' |read lpdt
else
  db2 "select * from $lib.ssdatep " |grep record |awk '{print $1}' |read rownum
  if [ "x$rownum" == "x" ]; then
    echo "get tstimestamp error ($image/$proj/$tn)"
    exit
  else
    db2 rollback >/dev/null
    db2 connect to C6SYSTEM user $db2user using $db2pass >/dev/null
    if [ $rownum -eq 1 ]; then
      db2 "select XSLPDT from $lib.ssdatep " |head -4 |tail -1 |\
        sed 's/[ .]//g' |read lpdt
    elif [ $rownum -eq 2 ]; then
      db2 "select XSLPDT from $lib.ssdatep where XSMDFL = 'P' " |head -4 |tail -1 |\
        sed 's/[ .]//g' |read lpdt
    else
      echo "get tstimestamp error ($image/$proj/$tn)"
      exit
    fi
  fi
fi
echo $lpdt |sed 's/\(....\)\(..\)\(..\)/\1-\2-\3/' |read lpdt
ts="$lpdt 00:00:00.000000"
echo $ts |tr -d '[-:. ]'|wc -ck |read tsCount
if [ $tsCount -ne 21 ];then
 echo "$fn,Get lpdt error"
 exit
fi

# get shwcutof
if [ "$type" != "Day1" ]; then
  if [ "x$shwcutof" == "x" ]; then
    db2 "select zatmze from aochubfp.ssjbavp where zajbnm = 'SSSHWCUTOF' " |\
      head -4 |tail -1 |read shwcutof
  fi
fi

case $type in
Day1)
    # get day1ts
    umask 000
    if [ $istts -eq 1 ]; then
       ttsstr=tts
    else
       ttsstr=""
    fi
    datadir=$dir/data_${ttsstr}day1 
    nulldatadir=$dir/null${ttsstr}day1
    datafile=$fn.$datets$inst.TXT
    dsjob -run -warn 0 -wait -param prmFilTarget=$datafile -param prmDirTarget=$datadir \
      -param prmUsrDB2=$db2user -param prmPwdDB2=$db2pass -param prmLibDB2=$lib \
      -param prmDteTimestamp="$ts" $proj $job 2>/dev/null
;;
Ongoing) 
    # date format: context   20080101T000000.000000000000
    # date format: timestamp 2008-08-11T16:28:31.641408

    # get mincutoffcontext
    db2 "select max(ORCONT) from aochubfp.orcdate3 where ORFLNM = '$tn' " |\
      head -4 |tail -1 |read mincutoffcontext

    # get maxcutoffcontext
    echo $shwcutof |sed 's/^\(..........\)-\(..\)\.\(..\)\.\(..\)/\1T\2:\3:\4/' |read cutoff
    . /sysp/attun50/navroot/bin/nav_login.sh
    cat >$rootdir/$$.sql <<EOF
select max(context) from $lib:"$tn" where timestamp <= '$cutoff';
EOF
    nav_util -b $lib execute $lib < $rootdir/$$.sql |head -4 |tail -1 |read maxcutoffcontext

    # start dsjob
    datafile=$fn.$datets.TXT
    dsjob -run -warn 0 -wait -param prmFilTarget=$datafile -param prmDirTarget=$dir \
      -param prmLibDB2=$lib -param tstimestamp="$ts" \
      -param cutoff="$maxcutoffcontext" -param lastcutoff="$mincutoffcontext" \
      $proj $job 2>/dev/null
;;
Date1)
    # date format: tmz 2008-01-01-00.00.00.000000

    # get mintmz
    db2 "select max(ortmz1) from aochubfp.orcdate1 where orflnm = '$tn'" |\
      head -4 |tail -1 |read mintmz

    # get maxtmz
    cat $rootdir/field.lst |grep "^$tn " |awk '{print $2}' |read col
    if [ "x" == "x$col" ]; then
      echo "can't get column name from field.lst"
      exit
    fi
    db2 "select max($col) from aochubfp.$tn where $col <= '$shwcutof' " |\
      head -4 |tail -1 |read maxtmz
    if [ "x" == "x$maxtmz" ]; then
      echo "$tn is empty in db2"
      exit
    fi

    # start dsjob
    datafile=$fn.$datets.TXT
    dsjob -run -warn 0 -wait -param prmFilTarget=$datafile -param prmDirTarget=$dir \
      -param username=$db2user -param password=$db2pass \
      -param mintmz="$mintmz" -param maxtmz="$maxtmz" \
      -param tstimestamp="$ts" $proj $job 2>/dev/null
;;
Date2)
    # date format: 20080101

    # get mintmz
    db2 "select max(ordat1) from aochubfp.orcdate2 where orflnm = '$tn' " |\
      head -4 |tail -1 |sed 's/[ .]//g' |read mintmz

    # get maxtmz
    echo ${shwcutof%-*} |sed 's/[ -]//g' |read maxtmz
    if [ "$mintmz" -eq "$maxtmz" ]; then
      echo "this job has been done successful today"
      exit
    fi

    # start dsjob
    datafile=$fn.$datets.TXT
    dsjob -run -warn 0 -wait -param prmFilTarget=$datafile -param prmDirTarget=$dir \
      -param username=$db2user -param password=$db2pass \
      -param mintmz="$mintmz" -param maxtmz="$maxtmz" \
      -param tstimestamp="$ts" $proj $job 2>/dev/null
;;
Date)
    dsjob -run -warn 0 -wait -param prmFilTarget=$fn.$datets.TXT -param prmDirTarget=$dir \
      -param username=$db2user -param password=$db2pass \
      -param tstimestamp="$ts" $proj $job 2>/dev/null
;;
esac

dsjob -lognewest $proj $job 2>/dev/null |awk -F'=' '/Newest id/ {print $2}' |read last
logrows=$((last-first))
if [ $logrows -gt 10000 ]; then
    logrows=10000
fi
dsjob -logsum -max $logrows $proj $job 2>/dev/null >$log

dsjob -jobinfo $proj $job 2>/dev/null |awk -F'[()]' '/Job Status/{print $2}' |read result

#ssh $sftpuser@$monhost mkdir /cygdrive/d/Hsbc_Project_Oracle/dsjob/$datedt/ >/dev/null 2>&1 &

cat $log |grep "records exported successfully" |awk '{print $4" "$8}' |read rowsucc rowfail
$rootdir/logchk.sh $log |xargs |read fatalwarntype

case $result in
1)  # RUN OK (1)
    echo "$image,$tn,SUCC($fatalwarntype),$log,$rowsucc,$rowfail"
    echo "$image,$tn,SUCC($fatalwarntype),$log" >>$logsumm
    ftplogs
    ls -l $datadir/$datafile |awk '{print $5}' |read sz
    if [ $sz -gt 0 ]; then
      runftp
      #touchfiles
      case $type in
      Ongoing)
          db2 "insert into aochubfp.orcdate3 (orflnm,orcont,orcutf) values ('$tn','$maxcutoffcontext','$shwcutof')" >/dev/null
      ;;
      Day1)    :
      ;;
      Date1)
          db2 "insert into aochubfp.orcdate1 (orflnm,ortmz1,orcutf) values ('$tn','$maxtmz','$shwcutof')" >/dev/null
      ;;
      Date2)
          db2 "insert into aochubfp.orcdate2 (orflnm,ordat1,orcutf) values ('$tn','$maxtmz','$shwcutof')" >/dev/null
      ;;
      Date)    :
      ;;
      esac
    else
      mv $datadir/$datafile $nulldatadir
    fi
;;
2)  # RUN with WARNINGS (2)
    echo "$image,$tn,WARN($fatalwarntype),$log,$rowsucc,$rowfail"
    echo "$image,$tn,WARN($fatalwarntype),$log" >>$logsumm
    ftplogs
    ls -l $datadir/$datafile |awk '{print $5}' |read sz
    if [ $sz -gt 0 ]; then
      runftp
      #touchfiles
      case $type in
      Ongoing)
          db2 "insert into aochubfp.orcdate3 (orflnm,orcont,orcutf) values ('$tn','$maxcutoffcontext','$shwcutof')" >/dev/null
      ;;
      Day1)    :
      ;;
      Date1)
          db2 "insert into aochubfp.orcdate1 (orflnm,ortmz1,orcutf) values ('$tn','$maxtmz','$shwcutof')" >/dev/null
      ;;
      Date2)
          db2 "insert into aochubfp.orcdate2 (orflnm,ordat1,orcutf) values ('$tn','$maxtmz','$shwcutof')" >/dev/null
      ;;
      Date)    :
      ;;
      esac
    else
      mv $datadir/$datafile $nulldatadir
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

