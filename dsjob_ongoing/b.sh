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

### function gettypename {{{
function gettypename {
    if [ $istts -eq 1 ]; then
        etctype=tts
    else
        etctype=hub
    fi
    grep -l "^$tn\$" $rootdir/etc/${etctype}*.lst |read f3
    f3=${f3##*/}
    f3=${f3#*4}
    f3=${f3%.*}
    echo $f3
}
# }}}

###
### main
###

proj=$1
tn=$2

# source db2 profile
export DB2CODEPAGE=1208
. /home/sds01pc/sds01pc1/sqllib/db2profile

# get user/pass if it is null
if [ -z "$hubdatabase" ]; then
    hubdatabase=B001
    hubuser=`/hsbc/orc/data/encrypt/getuid.sh hub.key hub.uid`
    hubpass=`/hsbc/orc/data/encrypt/getpwd.sh hub.key hub.uid`
fi

if [ -z "$ttsdatabase" ]; then
    ttsdatabase=N11SYS
    ttsuser=`/hsbc/orc/data/encrypt/getuid.sh tts.key tts.uid`
    ttspass=`/hsbc/orc/data/encrypt/getpwd.sh tts.key tts.uid`
fi

case $proj in
dpr_orc_prd)
    istts=0
    type=day1
    echo djpEXTday1$tn.$inst |sed 's/[#@]/_/g' |read job
    fn=$tn
    lib=AOCHUBFP
    database=$hubdatabase
    db2user=$hubuser
    db2pass=$hubpass
;;
dpr_orc_prd1)
    istts=1
    type=day1
    echo djpEXTday1$tn.$inst |sed 's/[#@]/_/g' |read job
    cat $rootdir/etc/ttslibname.txt |grep "^$tn " |awk '{print $2}' |read lib
    fn=$tn
    database=$ttsdatabase
    db2user=$ttsuser
    db2pass=$ttspass
;;
dpr_orc_prd2)
    istts=0
    gettypename |read type
    if [ "x$type" == "x" ]; then
        echo "type not found"
        exit 9
    fi
    echo djpEXT$type$tn |sed 's/[#@]/_/g' |read job
    fn=$tn
    database=$hubdatabase
    db2user=$hubuser
    db2pass=$hubpass
;;
dpr_orc_prd3)
    istts=1
    gettypename |read type
    echo djpEXT$type$tn |sed 's/[#@]/_/g' |read job
    fn=$tn
    database=$ttsdatabase
    db2user=$ttsuser
    db2pass=$ttspass
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
    echo "job: $job not found"
    exit
fi
dsjob -jobinfo $proj $job 2>/dev/null |awk -F'[()]' '/Job Status/{print $2}' |read status
if [ $status -eq 21 -o $status -eq 3 ]; then
    dsjob -run -mode RESET $proj $job >/dev/null 2>&1
fi

dsjob -lognewest $proj $job 2>/dev/null |awk -F'= ' '/Newest id/ {print $2}' |read first


# get tddt lpdt
if [ $istts -eq 1 ]; then
    db2 connect to $ttsdatabase user $ttsuser using $ttspass >/dev/null
    db2 "select XSLPDT,XSTDDT from AOCHSSFP.ssdatep " |\
        head -4 |tail -1 |read lpdt tddt
else
    db2 connect to $hubdatabase user $hubuser using $hubpass >/dev/null
    db2 "select XSLPDT,XSTDDT from AOCHUBFP.ssdatep " |\
        head -4 |tail -1 |read lpdt tddt
fi
echo $lpdt |sed 's/[ .]//g' |read lpdt
echo $tddt |sed 's/[ .]//g' |read tddt
# get lpdt error
echo $lpdt |grep -q "SQL"
if [ $? -eq 0 ]; then
    echo "get lpdt error"
    echo "lpdt: $lpdt"
    exit 9
fi

case $type in
day1)
    # get image tmz as ts

    echo $lpdt |sed 's/\(....\)\(..\)\(..\)/\1-\2-\3/' |read lpdt2
    ts="$lpdt2 00:00:00.000000"

    # start dsjob
    datafile=$fn.$datets$inst.TXT
    dsjob -run -warn 0 -wait -param prmFilTarget=$datafile -param prmDirTarget=$dir \
        -param prmSvrDB2=$database -param prmLibDB2=$lib \
        -param prmUsrDB2=$db2user -param prmPwdDB2=$db2pass \
        -param prmDteTimestamp="$ts" $proj $job 2>/dev/null
;;
ongoing) 
    # date format: cdc context   20080101T000000.000000000000
    # date format: cdc timestamp 2008-08-11T16:28:31.641408
    # date format: db2 TMZ       2008-08-11-16.28.31.641408

    if [ $istts -eq 1 ]; then
        etctype=TTS
    else
        etctype=HUB
    fi
    grep -l "^$tn\$" $rootdir/etc/*${etctype}*_SA |read lib
    lib=${lib##*/}

    #currentlastbatch="2008-11-01-12.37.48.376000"
    if [ -z "$currentlastbatch" ]; then
        db2 rollback >/dev/null
        db2 connect to $hubdatabase user $hubuser using $hubpass >/dev/null
        db2 "select zatmze from AOCHUBFP.ssjgavp where zajgid = 'SSSS999'" |\
            head -4 |tail -1 |read currentlastbatch
    fi
    tail -1 $rootdir/savedata/lastbatch |read lastlastbatch

    . /sysp/attun51/cnorc/navroot/bin/nav_login.sh
    #echo $currentlastbatch |tr -d '[-.]' |read currentlastbatch1
    #echo $lastlastbatch |tr -d '[-.]' |read lastlastbatch1
    #if [ $currentlastbatch1 -lt $lastlastbatch1 ]; then
    #  # batch is running
    #  echo "batch is running"
    #  exit 9
    #fi

    # get last context
    cat $rootdir/savedata/${etctype}lastcontext |grep "^$tn " |awk '{print $2}' |\
        tail -1 |read lastcontext
    if [ "x$lastcontext" == "x" ]; then
        cat >$rootdir/tmp/$$.sql <<EOF
select min(context) from $lib:"$tn" ; 
EOF
        nav_util -b $lib execute $lib < $rootdir/tmp/$$.sql |tail -4 |head -1 |read lastcontext
        if [ $lastcontext == "Null" ]; then
            # table is null
            echo "table $lib/$tn is null"
            rm -f $rootdir/tmp/$$.sql
            exit 9
        else
            lastcontext="20080101T000000.000000000000"
        fi
    fi

    # get current context
    #db2 connect to $hubdatabase user $hubuser using $hubpass >/dev/null
    #db2 "select zatmze from AOCHUBFP.ssjbavp where zajgnm = 'SSSHWCUTOF'" |\
    #  head -4 |tail -1 |read currentlastbatch
    currentlastbatch="2008-11-04-05.54.20.402000"
    currentlastbatch="2008-11-05-01.16.26.728000"
    currentlastbatch="2008-11-06-00.25.48.158000"

    echo $currentlastbatch |sed 's/^\(..........\)-\(..\)\.\(..\)\.\(..\)/\1T\2:\3:\4/' |read cdcts
    cat >$rootdir/tmp/$$.sql <<EOF
select max(context) from $lib:"$tn" where timestamp <= '$cdcts' ;
EOF
    nav_util -b $lib execute $lib < $rootdir/tmp/$$.sql |tail -4 |head -1 |read currentcontext
    if [ "$currentcontext" == "Null" ]; then
        echo "$tn" >> $rootdir/etc/Nulllpdt
        currentcontext=$lastcontext
    fi

    echo $currentcontext |tr -d '[T.]' |cut -c1-14 |read currentcontext1
    echo $lastcontext |tr -d '[T.]' |cut -c1-14 |read lastcontext1
    if [ $currentcontext1 -le $lastcontext1 ]; then
        cat >$rootdir/tmp/$$.sql <<EOF
select max(context) from $lib:"$tn" ;
EOF
        nav_util -b $lib execute $lib < $rootdir/tmp/$$.sql |tail -4 |head -1 |read currentcontext
        echo $tddt |sed 's/\(....\)\(..\)\(..\)/\1-\2-\3/' |read tddt2
        ts="$tddt2 00:00:00.000000"
    else
        echo $lpdt |sed 's/\(....\)\(..\)\(..\)/\1-\2-\3/' |read lpdt2
        ts="$lpdt2 00:00:00.000000"
    fi
    rm -f $rootdir/tmp/$$.sql

    #ts="2008-11-03 00:00:00.000000"
    # start dsjob
    datafile=$fn.$datets.TXT
    dsjob -run -warn 0 -wait -param prmFilTarget=$datafile -param prmDirTarget=$dir \
        -param prmLibDB2=$lib -param prmDteTimestamp="$ts" \
        -param prmDteBegin="$lastcontext" -param prmDteEnd="$currentcontext" \
        $proj $job 2>/dev/null
;;
date2)
    # date format: 20080101

    db2 connect to $database user $db2user using $db2pass >/dev/null
    db2 "select zatmze from $lib.ssjgavp where zajgid = 'SSSS999'" |\
        head -4 |tail -1 |read currentlastbatch
    tail -1 $rootdir/savedata/lastbatch |read lastlastbatch

    #if [ "$currentlastbatch" <= "$lastlastbatch" ]; then
    #  # batch is running
    #  exit 9
    #fi

    if [ "$tddt" != `date +%Y%m%d` ]; then
        # today is holiday
        exit 9
    fi

    echo $lpdt |sed 's/\(....\)\(..\)\(..\)/\1-\2-\3/' |read lpdt2
    ts="$lpdt2 00:00:00.000000"

    # get tmzfld
    cat $rootdir/etc/tmzfld.conf |grep "^$tn " |awk '{print $2}' |read tmzfld

    # start dsjob
    datafile=$fn.$datets.TXT
    dsjob -run -warn 0 -wait -param prmFilTarget=$datafile -param prmDirTarget=$dir \
        -param prmSvrDB2=$database -param prmLibDB2=$lib \
        -param prmUsrDB2=$db2user -param prmPwdDB2=$db2pass \
        -param prmSQLStr="where $tmzfld <= $lpdt" -param prmDteTimestamp="$ts" \
        $proj $job 2>/dev/null
        #-param prmDteBegin="$lpdt" -param prmDteTimestamp="$ts" \
;;
date)

    if [ -z "$currentlastbatch" ]; then
        db2 rollback >/dev/null
        db2 connect to $hubdatabase user $hubuser using $hubpass >/dev/null
        db2 "select zatmze from AOCHUBFP.ssjgavp where zajgid = 'SSSS999'" |\
            head -4 |tail -1 |read currentlastbatch
    fi
    tail -1 $rootdir/savedata/lastbatch |read lastlastbatch

    echo $currentlastbatch |tr -d '[-.]' |read currentlastbatch1
    echo $lastlastbatch |tr -d '[-.]' |read lastlastbatch1

echo $currentlastbatch
echo $currentlastbatch1
echo $lastlastbatch
echo $lastlastbatch1

    if [ $currentlastbatch1 -lt $lastlastbatch1 ]; then
      # batch is running
      echo "batch is running"
      exit 9
    fi

exit

    if [ $istts -eq 1 ]; then
        cat $rootdir/etc/ttslibname.txt |grep "^$tn " |awk '{print $2}' |read lib
    else
        echo AOCHUBFP |read lib
    fi

    echo $lpdt |sed 's/\(....\)\(..\)\(..\)/\1-\2-\3/' |read lpdt2
    ts="$lpdt2 00:00:00.000000"

    debug=0
    if [ $debug -eq 1 ]; then
        echo $database
        echo $lib
        echo $db2user
        echo $db2pass
        echo $ts
        exit
    fi

    # start dsjob
    datafile=$fn.$datets.TXT
    dsjob -run -warn 0 -wait -param prmFilTarget=$datafile -param prmDirTarget=$dir \
        -param prmSvrDB2=$database -param prmLibDB2=$lib \
        -param prmUsrDB2=$db2user -param prmPwdDB2=$db2pass \
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
            #rm -f $dir/$datafile
            echo "$tn $currentcontext" >> $rootdir/savedata/${etctype}lastcontext
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

db2 disconnect $database >/dev/null

exit

# vim:foldmethod=marker:foldenable:foldlevel=0

