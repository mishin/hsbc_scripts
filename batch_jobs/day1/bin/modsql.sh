#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -eq 0 ]; then
  exit
fi

if [ $tts -eq 1 ]; then
  conf=$rootdir/etc/sql.tts.conf
else
  conf=$rootdir/etc/sql.hub.conf
fi
tn=$1

cat $conf |grep "^$tn " |while read tmp coln sql ; do

$VI $rootdir/tmp/$tn.dsx <<EOF
1G/^SELECT
/^$coln 
cW$sql:wq
EOF

done

