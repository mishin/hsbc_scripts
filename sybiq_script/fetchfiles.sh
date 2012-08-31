#!/bin/ksh 

SSH="/usr/local/bin/ssh"
sshstr="orcftp1@130.37.65.11#9922"
SCP="/usr/local/bin/scp"
scpstr="orcftp1@130.37.65.11#37021"

export PATH=/usr/local/bin:$PATH
localdir=/sybiq/script
remotedir=/hsbc/orc/data/alldata
log=$localdir/log
timestr=`date +%Y%m%d%H%M%S`
scriptName=`basename $0`

# Redirect standard output and standard error to log file
OUT=$log/${scriptName}.${timestr}.log
exec 1>> ${OUT} 2>&1


$SSH $sshstr "ls $remotedir/data_*.flag" > $log/$$.${timestr}.flag 2>/dev/null

if [ $? -ne 0 ];then
  echo "There is not flag file in $remotedir directory "
  rm -f $log/$$.${timestr}.flag
  exit 9 
else 
  # Delete the flag file 
  $SSH $sshstr "rm -f $remotedir/data_*.flag" 2>/dev/null 

  allflag=`cat $log/$$.${timestr}.flag | sed -e "s%$remotedir/%%g" ` 
  for rd in $allflag ; do
    rd=${rd%%.flag}
    pid=$log/$$.pid 
    loadpid=$log/$$.loadpid 
    >$pid
    >$loadpid
    if [ ! -d $localdir/$rd ];then
      echo "$localdir/$rd is not exist"
      rm -f $pid $loadpid
      continue
    fi 

    # Get the Remote TXT list
    $SSH $sshstr "$remotedir/getlist.sh $remotedir/$rd " >$log/${rd}.${timestr}.dslst 2>/dev/null
    cat $log/${rd}.${timestr}.dslst|wc -l |read dsnum 
    if [ $dsnum -eq 0 ];then
      echo "No TXT file in remote $remotedir/$rd "
      rm -f $pid $loadpid
      continue
    fi

    ################# Prepare Loading and then Start Load ##################
    # Get the Remote TXT to local dir
    trap '
      echo I am exiting ...
      kill -USR1 `cat $log/$$.pid |xargs`
      EXIT=1
    ' INT TERM
    EXIT=0

    # Get the TXT file form Remote Server : homedir=/hsbc/orc/data
    for i in A B C D E F G H I J K L M N O P Q R S T U V W X Y Z;do
      cat $pid |wc -l |read curr
      if [ $curr -ge 10 ]; then
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
          done
          sleep 2
        done
      fi
      $SCP -r $scpstr:alldata/$rd/[${i}]*.TXT $localdir/$rd >/dev/null 2>/dev/null &
      sleep 2
      echo $! >>$pid
    done
    wait
    ################### SCP Remote TXT File END ...#############################

    # Get the Local TXT list
    cat $log/${rd}.${timestr}.dslst|while read size filename ;do
      ls -l $localdir/$rd/$filename 2>/dev/null | awk '{print $5}' |read lsize
      if [[ $lsize -eq $size ]];then
         echo $filename >>$log/${rd}.${timestr}.syblst
      else
         echo $filename >>$log/${rd}.${timestr}.difflst
         rm -f $localdir/$rd/$filename 
      fi
    done

    # Start removing remote file and Loading local data file
    cat $log/${rd}.${timestr}.syblst |wc -l |read sybnum

    if [[ $sybnum -ne 0 ]];then

      # Delete the Remote Server TXT-file 
      dslst=`cat $log/${rd}.${timestr}.syblst`
      for rfn in $dslst ; do
        $SSH $sshstr "rm -f $remotedir/$rd/$rfn " 2>/dev/null
      done &

      cd $localdir/$rd

      ################## Read the data filename and Load into SybaseIQ ##################
      trap '
      echo i am exiting ...
      kill -USR1 `cat $log/$$.loadpid |xargs`
      EXIT=1
      ' INT TERM
      EXIT=0

      for i in A B C D E F G H I J K L M N O P Q R S T U V W X Y Z ;do
        cat $loadpid |wc -l |read curr
        if [ $curr -ge 5 ]; then
          while true ; do
            if [ $EXIT -eq 1 ]; then
               break 99
            fi
            cat $loadpid |while read p ; do
              ps -p $p >/dev/null
              if [ $? -eq 1 ]; then
                cat $loadpid |grep -vw $p > $$
                mv -f $$ $loadpid
                break 2
              fi
            done
            sleep 2
          done
        fi
        cat $log/${rd}.${timestr}.syblst | grep "^$i"|while read lfn ;do
          if [ "X$lfn"!="X" ];then 
           $localdir/load.sh ${rd##data_} $lfn 
          fi
          :
        done >$log/${rd}.${timestr}.$i.loadlog &
        sleep 1
        echo $! >>$loadpid
      done
      wait
      #################### Load END ... ################################################

      cat $log/${rd}.${timestr}.[A-Z].loadlog>$log/${rd}.${timestr}.loadlog
      #cat $log/${rd}.${timestr}.loadlog | grep "failed" >/dev/null  && \
      #   logger -t root "ORC2002X : LOAD ERROR,refer to $log/${rd}.${timestr}.loadlog "
      rm -f $log/${rd}.${timestr}.[A-Z].loadlog
    else
      echo "Remote-list not match Local-list or get null List"
      continue
    fi 
    rm $pid $loadpid
  done
fi 
