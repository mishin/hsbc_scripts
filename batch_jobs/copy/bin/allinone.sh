#!/usr/bin/ksh

. `dirname $0`/env.sh

cd $rootdir/job

for h in A B C D E F G H I J K L M N O P Q R S T U V W X Y Z ; do
  ls ${h}*.dsx >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    ls ${h}*.dsx |head -n 1 |read base
    cat "$base" |awk '/^BEGIN HEADER/,/^END HEADER/ {print}' > $rootdir/day1jobs_$h.dsx
    for i in ${h}*.dsx ; do
      cat $i |awk '/^BEGIN DSJOB/,/^END DSJOB/ {print}' >> $rootdir/day1jobs_$h.dsx
    done
  fi
done
