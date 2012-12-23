#!/bin/ksh
#
# limit parameter
#
if [ $# -ne 2 ];then
  echo "Usage:$0 projectName tableName"
  echo "ex. $0 dpr_orc_prd2 BAOMTHP"
  exit 9
fi
#
# Initialize Variable
#
releaseTableName=$1 
baseDir=/hsbc/orc/data/dsjob_ongoing
dsLogDir=$baseDir/log/dslog
dataDir=/hsbc/orc/data/alldata
dateStr=`date +%Y%m%d`
#echo $currTableName
#echo $dateStr
#echo $dslogName 
#
# define message function
#
message () {
cat <<- ENDOFTEXT
 
  Now is `date +"%Y-%m-%d %H:%M:%S"`
  You can do these work :
   (1) Import datastage job and compile it ;
   (2) Modify load sql ;
   (3) Modify SybaseIQ DB table define ;

ENDOFTEXT
}

#message
#exit

ls -rt $dsLogDir/*.${dateStr}*.dslog|sed -e 's%^.*/%%'|read dslogName 
list=${dslogName%%.*}.lst
cat $dsLogDir/$dslogName |grep "${releaseTableName}," |wc -l|read chklog

if [ $chklog -ne 0 ];then  
  #Check the dslog 
  cat $dsLogDir/$dslogName |grep "${releaseTableName},"|awk -F',' '{print $5}'|read records 
  if [ "X$records" == "X" ];then
    records=0
  fi 
  if [ $records -ne 0 ];then
    #will to load 
    #FTP
    #LOAD 
    echo "the runned job get $records records"
    echo "you must load the data to SYBASE IQ DB "
  else 
    #
    echo "the runned job get 0 recoreds "
    message
    exit
  fi 
else
  #Check the processes
  ps -ef|grep "dsjob_sche.sh"|grep "dsjob_ongoing" |grep "${releaseTableName}"|wc -l|read chkpro
  if [ $chkpro -ne 0 ];then
    # please Waiting a monment ... 
    echo "Waiting a monment ..."
    continue 
  else 
    # get the running job name
    ps -ef|grep "dsjob_sche.sh"|grep "dsjob_ongoing"|sort -k5| \
      awk '{print $NF}'|tail -1|read currJobName    
    if [ "X$currJobName" == "X" ];then
      echo "ongoing job is finished,there is not any job running."
      exit 
    fi
    # get the running job sequence number
    grep -n " ${currJobName}" $baseDir/$list | \
      awk -F':' '{print $1}'|read currSequNumber
    # get the Release job sequence number
    grep -n " ${releaseTableName}" $baseDir/$list | \
      awk -F':' '{print $1}'|read relSequNumber
    # get the summation list number
    cat $baseDir/$list |wc -l|read listNum
    # echo some message
    echo "current running job : $currJobName \tSequence Number : ${currSequNumber}"
    echo "the   Release   job : $releaseTableName \tSequence Number : ${relSequNumber}"
    echo "You can extract the $releaseTableName data and then load to Sybase IQ DB" 
    continue 
  fi
fi
