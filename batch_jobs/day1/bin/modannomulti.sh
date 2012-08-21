#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -ne 1 ]; then
  exit 9
fi

tn=$1
job=$rootdir/tmp/$tn.dsx

if [ "$tbtype" == "day1" ]; then
  prefix=""
else
  prefix="ongoing_"
  sed -i '/AllowMultipleInvocations/s/1/0/' $job
fi

sed -i '/^  *AnnotationText /,/^=+=+=+=/c\
      AnnotationText =+=+=+=\
extract data from db2 ('"$tn"')\
'"$prefix$tbtype"' phase\
=+=+=+=' $job


exit

