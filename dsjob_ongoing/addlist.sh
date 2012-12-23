#!/bin/ksh
if [ $# -ne 2 ];then
  echo "Usage : $0 <hub|tts> <File_CSV_Name>"
  exit 9
fi

basedir=/hsbc/orc/data/dsjob_ongoing
timestr=`date +%Y%m%d%H%M%S`
type=$1
csvFile=$2

# ---------------------------------------
# be sure the csv file exist !
# ---------------------------------------
if [ ! -f $csvFile ];then
  echo "Illegal File : $csvFile is not exist! "
  exit 9
fi

##############################################################################
## Update lists:
##  		etc/hub4date.lst
## 		etc/tts4date.lst
## 		hubttsdate.lst
## 		hubttsall.lst
##############################################################################
case $type in
hub) 
  # ---------------------------------------
  # set hub project name in datastage 
  # ---------------------------------------
  proj_name=dpr_orc_prd2
  
  # ---------------------------------------
  # Backup hub lists 
  # ---------------------------------------
  cp $basedir/etc/hub4date.lst $basedir/etc/bak/hub4date.lst.${timestr}
  cp $basedir/hubttsdate.lst $basedir/etc/bak/hubttsdate.lst.${timestr}
  cp $basedir/hubttsall.lst $basedir/etc/bak/hubttsall.lst.${timestr}

  # ---------------------------------------
  # NOT Update library for hub : AOCHUBFP 
  # Get lastest table 
  # by reading the csv file  
  # And update hub lists according to the names
  # ---------------------------------------
  cat $csvFile |awk -F',' '{print$1" "$2}'|sort|uniq >${csvFile}.$$
  cat ${csvFile}.$$ | while read tn lib;do
    if [ "X$tn" == "X" ] || [ "$lib" != "AOCHUBFP" ];then
       echo "Illegal tableName / library name"
       continue 
    fi
    # Update the etc/hub4date.lst
    cat $basedir/etc/hub4date.lst|grep -q "^$tn$" 
    if [ $? -ne 0 ];then
      echo "$tn" >> $basedir/etc/hub4date.lst
    fi

    # Update the hubttsdate.lst
    cat $basedir/hubttsdate.lst|grep $proj_name | grep -q " $tn$"
    if [ $? -ne 0 ];then
      echo "$proj_name $tn" >> $basedir/hubttsdate.lst
    fi

    # Update the hubttsall.lst
    cat $basedir/hubttsall.lst |grep $proj_name | grep -q " $tn$"
    if [ $? -ne 0 ];then
      echo "$proj_name $tn" >> $basedir/hubttsall.lst
    fi
  done
  rm -f ${csvFile}.$$
  # ---------------------------------------
  # Updating hub list end !
  # ---------------------------------------
;;
tts)   
  # ---------------------------------------
  # set tts project name in datastage 
  # ---------------------------------------
  proj_name=dpr_orc_prd3

  # ---------------------------------------
  # Backup tts lists 
  # ---------------------------------------
  cp $basedir/etc/ttslibname.txt $basedir/etc/bak/ttslibname.txt.${timestr}
  cp $basedir/etc/tts4date.lst $basedir/etc/bak/tts4date.lst.${timestr}
  cp $basedir/hubttsdate.lst $basedir/etc/bak/hubttsdate.lst.${timestr}
  cp $basedir/hubttsall.lst $basedir/etc/bak/hubttsall.lst.${timestr}

  # ---------------------------------------
  # Get tts name and library
  # by reading the csv file 
  # And update the tts lists
  # ---------------------------------------
  cat $csvFile |awk -F',' '{print$1" "$2}'|sort|uniq >${csvFile}.$$
  cat ${csvFile}.$$ | while read tn lib;do
    if [ "X$tn" == "X" ] || [ "X$lib" == "X" ];then
      echo "Illegal tableName / library name: Null name!"
      continue
    fi
    # Adding new table and library name
    cat $basedir/etc/ttslibname.txt |grep -q "^$tn "
    if [ $? -ne 0 ];then
      echo "$tn $lib" >> $basedir/etc/ttslibname.txt
    fi

    # Update the tts4date.lst
    cat $basedir/etc/tts4date.lst|grep -q "^$tn$"
    if [ $? -ne 0 ];then
      echo "$tn" >> $basedir/etc/tts4date.lst
    fi

    # Update the hubttsdate.lst
    cat $basedir/hubttsdate.lst |grep $proj_name | grep -q " $tn$"
    if [ $? -ne 0 ];then
      echo "$proj_name $tn" >> $basedir/hubttsdate.lst
    fi

    # Update the hubttsall.lst
    cat $basedir/hubttsall.lst |grep $proj_name | grep -q " $tn$"
    if [ $? -ne 0 ];then
      echo "$proj_name $tn" >> $basedir/hubttsall.lst
    fi
  done
  rm -f ${csvFile}.$$
  # ---------------------------------------
  # Updating tts list end !
  # ---------------------------------------
;;
*)
  echo "Input Type ERROR"
esac
