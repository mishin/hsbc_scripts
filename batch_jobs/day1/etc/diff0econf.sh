#!/usr/bin/ksh

if [ $# -ne 2 ]; then
  echo "$0 hub|tts hub1.0e.job"
  exit 9
fi

case $1 in
hub)
  conf=0e.hub.conf
;;
tts)
  conf=0e.tts.conf
;;
esac

new=$2

dos2unix $new 2>/dev/null

cat $conf |awk -F',' '{print $1","$2","}' >$conf.$$
cat $new |awk -F',' '{print "^"$1","$2","}' >$new.$$

# only in $conf
grep -vf $new.$$ $conf.$$ |sed 's/^/^/' >$$
grep -f $$ $conf >$$.1

cp -f $conf $conf.`date +%Y%m%d%H%M%S`
cat $$.1 $new |sort >$conf

rm -f $conf.$$ $new.$$ $$ $$.1

exit

