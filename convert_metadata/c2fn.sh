#!/usr/bin/ksh

cat /tmp/ongoingtb |while read a ; do
echo -n "$a,"
dlup=N
c2fn=N
c2sn=N
c2cn=N
cat "$a" |grep -q DLUP
if [ $? -eq 0 ]; then
dlup=Y
fi
cat "$a" |grep -q C2FN
if [ $? -eq 0 ]; then
c2fn=Y
fi
cat "$a" |grep -q C2SN
if [ $? -eq 0 ]; then
c2sn=Y
fi
cat "$a" |grep -q C2CN
if [ $? -eq 0 ]; then
c2cn=Y
fi
echo "$dlup,$c2fn,$c2sn,$c2cn"
done >/tmp/out
