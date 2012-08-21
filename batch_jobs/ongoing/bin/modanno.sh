#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -ne 1 ]; then
  exit 9
fi

tn=$1
job=$rootdir/tmp/$tn.dsx

sed -i '/^  *AnnotationText /,/^=+=+=+=/c\
      AnnotationText =+=+=+=\
extract data from attunity CDC ('"$tn"')\
ongoing phase\
=+=+=+=' $job

