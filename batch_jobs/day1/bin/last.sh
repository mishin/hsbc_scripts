#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -ne 1 ]; then
  exit 9
fi

tn=$1
job=$rootdir/tmp/$tn.dsx

uname |read os
case $os in
Linux)
  unix2dos $job 2>/dev/null
;;
AIX)
  $VI +1 $job <<EOF
:%s/$//
:%s/$/\\/
:wq
EOF
;;
*)
  echo "os not supported"
  exit 9
;;
esac

mv -f $job $rootdir/job/

