#!/usr/bin/ksh

for a in t/* ; do
a=${a##*/}
echo -n "$a,"
psdt=''
cat t/"$a" |grep PSDT |awk -F ',' '{print $2}' |read psdt
echo "$psdt"
done >/tmp/out

