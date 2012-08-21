#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -eq 0 ]; then
  exit
fi

tn=$1

cd $rootdir/job
$VI +1 $tn.dsx <<EOF
:%s/$//
:%s/$/\\/
:wq
EOF

