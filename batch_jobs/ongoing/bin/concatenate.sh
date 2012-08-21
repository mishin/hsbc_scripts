#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -eq 0 ]; then
  exit
fi

tn=$1

out=$rootdir/tmp/$tn.dsx
cp -f /dev/null $out

cd $rootdir/tmp

ls demopart[0-9]* |wc -l |read num
i=0
while [ $i -lt $num ]; do
  cat demopart$i.* >>$out
  i=$((i+1))
done

echo "END DSJOB" >>$out

