#!/usr/bin/ksh 

if [ $# -ne 3 ];then
  echo "Usage: $0 <db2log> <dslog> <loadlog> "
  exit
fi

db2log=$1
dslog=$2
loadlog=$3
if [[ ! -f $db2log || ! -f $dslog || ! -f $loadlog ]];then
    echo "error : $db2log ,$dslog or $loadlog is not exist"
    exit
fi

alljob=0
allload=0

allimage=`cat $db2log|awk '{print $1}'|sort|uniq`
for image in $allimage;do
  db2num=""
  dsnum=""
  loadnum=""
  jobnum=""
  abnormity=""
  ftpnum=""
  loadsum=""
  succload=""
  failload=""
  nullnum=""

  case $image in
    oraclehub1|oracletts1) i=1
  ;;
    oraclehub2|oracletts2) i=2
  ;;
    oraclehub3|oracletts3) i=3
  ;;
    oraclehub4|oracletts4) i=4
  ;;
    *)
    echo "Error : image"
    continue 
  esac
  echo
  echo "imageName\t tableName\t db2Count\t dsCount\t loadCount"
  echo ======================================================================

  cat $db2log|grep "^$image" |sed 's/[#@$]/_/g' >$db2log.$$
  cat $dslog|grep "^$image,"|grep -v -e "FAIL" -e "is null" -e "Waiting" |\
    awk -F',' '{print $2" "$5}'|sed 's/[@#$]/_/g'>$dslog.$$
  cat $loadlog|grep "[0-9]${i}\.TXT"|awk -F'[.,]' '{print$1" "$NF}'|sed 's/[#@$]/_/g' >$loadlog.$$

  cat $db2log.$$ | while read img tablename db2num;do
    (cat $dslog.$$ | grep "^$tablename " || echo NULL NULL) |awk '{print$2}' | read dsnum
    (cat $loadlog.$$ | grep "^$tablename " ||echo NULL NULL) |awk '{print$2}' | read loadnum
    if [[ $db2num != $dsnum ]] || [[ $db2num != $loadnum ]];then
      echo "$image\t $tablename\t $db2num\t $dsnum\t\t $loadnum"
    fi
  done 

  cat $db2log.$$ | wc -l | read jobnum
  cat $dslog|grep "^$image," |grep -v -e "is null" -e "Waiting" -e "WARN()" -e "SUCC()"|wc -l|read  abnormity
  cat $dslog.$$|awk '{if($NF>0){print}}'|wc -l|read ftpnum
  cat $dslog.$$|awk '{if($NF=0){print}}'|wc -l|read nullnum
  cat $loadlog.$$ | wc -l | read loadsum
  cat $loadlog | grep "[0-9]${i}\.TXT" | grep -e "succ" | wc -l|read succload
  cat $loadlog | grep "[0-9]${i}\.TXT" | grep -v -e "succ" | wc -l|read failload
   
  echo 
  echo "-------${image}-------------" 
  echo "sum  job  num    :  $jobnum "
  echo "abnormity job    :  $abnormity"
  echo "succ get  txt    :  $ftpnum "
  echo "load sum  num    :  $loadsum"
  echo "succ load num    :  $succload"
  echo "fail load num    :  $failload"
  echo "------------------------------" 
  echo

  if [ $((ftpnum+nullnum+abnormity)) -ne $jobnum ];then
     echo "$image : WANRING,THE DS NUMBER IS NOT CORRECT!"
  else 
     alljob=$((alljob+jobnum)) 
  fi
  if [ $((succload+failload)) -ne $ftpnum ];then
     echo "$image : WANRING,THE LOAD NUMBER IS NOT CORRECT!"
  else
     allload=$((allload+ftpnum))
  fi

  echo ===============================================================
  echo 
  rm -f $db2log.$$ $dslog.$$ $loadlog.$$ 

done

