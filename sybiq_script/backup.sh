#!/bin/ksh
# ################################################
# script name 	:	backup.sh  
# edit   date 	:	2009-05-04
# version   	:	0.1
# purpose 	:	backup data file 
# ################################################

if [ $# -ne 2 ];then
  echo "Usage: $0 type fileName"
  echo "expl.: $0 type fileName"
  exit 9
fi
# ------------------------------------------------
# Initialize var.
# ------------------------------------------------
type=$1
file=$2

# ------------------------------------------------
# Set base direction
# ------------------------------------------------
basedir=/sybiq/script/backup
done=$basedir/done_$type

# ------------------------------------------------
# See file/dir is exist or not
# ------------------------------------------------
if [ ! -f $file ] || [ ! -d $done ];then
  echo "Illegal file or dir : $file or $done not found "
  exit 9
fi

# ------------------------------------------------
# Get the date of image
# ------------------------------------------------
head -1 $file|cut -c1-10|tr -d '-'|read datestr
if [ ! -d $done/$datestr ];then
 mkdir $done/$datestr >/dev/null
fi

# ------------------------------------------------
# Move the date file and sql file to dest 
# and then backup them
# ------------------------------------------------
mv -f $file $done/$datestr
mv -f ${file%%.TXT.orig}.sql $done/$datestr
gzip $done/$datestr/${file##*/}

# ------------------------------------------------
# finished
# ------------------------------------------------
exit 0


