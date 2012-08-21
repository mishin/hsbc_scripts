#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -eq 0 ]; then
  exit
fi

tn=$1

out=$rootdir/job/$tn.dsx
cp -f /dev/null $out

cd $rootdir/demo_job

ls part[0-9]* |wc -l |read num
i=0
while [ $i -lt $num ]; do
  cat part$i.* >>$out
  i=$((i+1))
done

echo "END DSJOB" >>$out

