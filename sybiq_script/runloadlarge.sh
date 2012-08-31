#!/bin/ksh 
#
# **********************************************************************************
# Script Name   : runloadlarge.sh
# Author        : Yue Yantao
# Create Date   : 2009-06-15
# Version       : 0.1
# Description   : The script to get large data file from remote server and the load
#		 +the large data file ,which only for day1 stage
# Usage         : Run without any parameter
# **********************************************************************************

SSH="/usr/bin/ssh"
sshstr="-p 22 orcftp1@130.37.65.11"
SCP="/usr/bin/scp"
scpstr="-P 22 orcftp1@130.37.65.11"

export PATH=/usr/bin:$PATH
localdir=/sybiq/script
remotedir=/hsbc/orc/data/alldata
log=$localdir/day1log
timestr=`date +%Y%m%d%H%M%S`
scriptName=`basename $0`


$SSH $sshstr "ls $remotedir/data_largeday1/*.largeflag" > $log/$$.${timestr}.largelst 2>/dev/null

if [ $? -ne 0 ];then
  echo "There is not flag file in $remotedir/data_large directory "
  rm -f $log/$$.${timestr}.largelst
  exit 9 
else 
  # --------------------------------
  # Delete the flag file 
  # --------------------------------
  for largefileflag in `cat $log/$$.${timestr}.largelst` ;do
    $SSH $sshstr "rm -f $largefileflag" 2>/dev/null
  done
  
  # --------------------------------
  # Start load
  # --------------------------------
  allflag=`cat $log/$$.${timestr}.largelst | sed -e "s%$remotedir/%%g" ` 
  for largefile in $allflag ; do
    largefile=${largefile%%.largeflag}
    if [ ! -f $localdir/$largefile ];then
      echo "$localdir/$largefile is not exist"
      continue
    fi 
    # -------------------------------------------------
    # compare the Remote TXT size and local TXT size
    # -------------------------------------------------
    $SSH $sshstr "ls -l $remotedir/$largefile" 2>/dev/null |awk '{print$5}' \
      |read remotesize 
    ls -l $localdir/$largefile 2>/dev/null | awk '{print $5}' |read localsize
    if [ $remotesize -eq $localsize ];then
      cd $localdir/data_day1 && mv $localdir/$largefile . && \
      $localdir/load.sh day1 ${largefile##*/} && \
      $SSH $sshstr "rm -f $remotedir/$largefile" 2>/dev/null  
    else
      echo "the size can't match"
      ls -l $localdir/$largefile >> $log/$$.${timestr}.largedifflst
      rm -f $localdir/$largefile 
    fi
  done
fi 
