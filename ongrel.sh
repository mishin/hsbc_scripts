#!/usr/bin/ksh -x
# ----------------------------------------------------------------
# set input var
# ----------------------------------------------------------------
if [ $# -ne 3 ];then
 echo "  Usage: $0 <cdc|nocdc> <hub|tts> <csvfile_name> "
 echo "  example: $0 nocdc hub ORACLEhub5.csv "
 exit 9
fi

# ----------------------------------------------------------------
# init vars
# ----------------------------------------------------------------
iscdc=$1
type=$2
csvfile=`basename $3`

# ----------------------------------------------------------------
# check the iscdc,type & csvfile var.
# ----------------------------------------------------------------
case $iscdc in
	nocdc)
 		isday1=day1
 		isdate=date
 	;;
	cdc)
 		isday1=ongoing
 		isdate=cdc
 	;;
	*)
 		echo "You input the nocdc error: $iscdc"
 		exit 9
	;;
esac

case $type in
	hub|tts)
		type_tmp=`echo $csvfile|sed 's/ORACLE//;s/\.csv//;'`
		type_tmp2=`echo $csvfile|sed 's/ORACLE//;s/[56]\.csv//;'`
		if [ "${type}" != "${type_tmp2}" ];then
			echo "Input error: $type $csvfile"
			exit
		fi
	;;
	*)
		echo "Input error var.: $type"
		exit
	;;
esac

# ----------------------------------------------------------------
# define the default directory 
# ----------------------------------------------------------------
dateStr=`date +%Y%m%d%H%M%S`
rootDir=/home/yyt/hsbc_script/file_struct_diff/ongoing
rootDirDay1=/home/yyt/hsbc_script/file_struct_diff/day1
batchDir=/home/yyt/hsbc_script/batch_jobs
logdir=/tmp/log
logname=$logdir/$iscdc.$type.${dateStr}.log
[ ! -d $logdir ] && mkdir -p $logdir

# ----------------------------------------------------------------
# cd hubstruct/1212.changed
# ----------------------------------------------------------------
cd $rootDir/${type}struct
mkdir ${dateStr}.changed && cd ${dateStr}.changed || \
  (echo "mkdir ${dateStr}.changed error ";exit 9 )

# ----------------------------------------------------------------
# split the csv file
# ----------------------------------------------------------------
echo "Starting split the $csvfile ..."
if [ -f /tmp/$csvfile ];then 
  ${rootDirDay1}/split.sh /tmp/$csvfile
else
 echo "not find csvfile in /tmp/$csvfile "
 exit 9
fi

mkdir $iscdc bak && ( cp $type_tmp/* $iscdc ;dos2unix $iscdc/* >/dev/null 2>&1 )

# ----------------------------------------------------------------
# compare the new struct
# ----------------------------------------------------------------
echo "Starting compare the new Struct ... "
${rootDirDay1}/diff.sh $type $iscdc ../$type ./$iscdc |tee $logname
ls ./$iscdc.job/* >/dev/null 2>&1
if [ $? -ne 0 ];then
 echo "no files exist in $iscdc" 
 exit 9
fi

# ----------------------------------------------------------------
# Batch  the new job
# ----------------------------------------------------------------
echo "Starting batch the jobs ..."
cd $batchDir/$isday1
rm -rf tb/* job/*
cp $rootDir/${type}struct/${dateStr}.changed/$iscdc.job/* $batchDir/$isday1/tb
cd $batchDir/$isday1/bin
if [[ "$iscdc" == "nocdc" ]];then
 ./runme.sh $type $isdate
else
 ./runme.sh $type 
fi

# ----------------------------------------------------------------
# Meger the job
# ----------------------------------------------------------------
echo "Meger the job & sql files ..."
ls $batchDir/$isday1/job/*.dsx|head -1|read first
head -11 $first >/tmp/${dateStr}.dsx
cat $batchDir/$isday1/job/*.dsx |\
  awk '/^BEGIN DSJOB/,/^END DSJOB/{print}'>>/tmp/${dateStr}.dsx

# ----------------------------------------------------------------
# Package the load & mod 
# ----------------------------------------------------------------
echo "Package the load & mod files ... "
cd $rootDir/${type}struct/${dateStr}.changed
ls $iscdc.mod/*.sql >/dev/null 2>&1 && cat $iscdc.mod/*.sql>>/tmp/${type}_${iscdc}.mod.sql
ls $iscdc.load/*.sql >/dev/null 2>&1 && tar -cf ${type}_${iscdc}.load.tar $iscdc.load
ls ${type}_${iscdc}.load.tar >/dev/null 2>&1 && mv ${type}_${iscdc}.load.tar /tmp

# ----------------------------------------------------------------
# Backup && Update the 4date.lst or 4cdc.lst
# ----------------------------------------------------------------
ls -1 $rootDir/${type}struct/${dateStr}.changed/$iscdc |while read tb;do
 cat $rootDir/${type}struct/4${isdate}.lst|grep -qw "$tb"
 if [ $? -ne 0 ];then
  echo "Update the local list ... "
  cp $rootDir/${type}struct/4${isdate}.lst $rootDir/${type}struct/4${isdate}.lst.${dateStr}
  echo $tb >> $rootDir/${type}struct/4${isdate}.lst
 fi
 if [ -f $rootDir/${type}struct/$type/$tb ];then
  cp $rootDir/${type}struct/$type/$tb $rootDir/${type}struct/${dateStr}.changed/bak 
 fi
  cp -f $rootDir/${type}struct/${dateStr}.changed/$iscdc/$tb \
        $rootDir/${type}struct/$type/$tb
done
# ----------------------------------------------------------------
# end and then exit!
# ----------------------------------------------------------------
exit

