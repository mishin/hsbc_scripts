#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -eq 0 ]; then
  exit
fi

conf=$rootdir/etc/finaldelim.conf
tn=$1

cat $conf |grep -q "^$tn\$"
if [[ $? -eq 0 || $tts -eq 1 ]]; then

str=#!
job=$rootdir/tmp/$tn.dsx
sed -i "/^  *Value.*final_delim=none/s/final_delim=none/final_delim_string='$str'/" $job

fi

