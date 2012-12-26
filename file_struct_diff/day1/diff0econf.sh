#!/usr/bin/ksh

if [ $# -ne 2 ]; then
  echo "$0 [hub|tts] hub1.0e.job"
  exit 9
fi

case $1 in
hub)
  conf=0e.hub.conf
;;
tts)
  conf=0e.tts.conf
;;
*)
  echo "parameter #1 is error"
  exit 9
;;
esac

new=$2
basedir=`dirname $0`
bakdir=$basedir/bak

#dos2unix $new 2>/dev/null
cat $new |sed 's///' >$new.1

cat $conf |awk -F',' '{print $1","$2","}' >$conf.$$
cat $new.1 |awk -F',' '{print "^"$1","$2","}' >$new.$$

# only in $conf
grep -vf $new.$$ $conf.$$ |sed 's/^/^/' >$$
grep -f $$ $conf >$$.1

confbak=$conf.`date +%Y%m%d%H%M%S`
cp -f $conf $bakdir/$confbak
cat $$.1 $new.1 |sort >$conf

rm -f $new.1 $conf.$$ $new.$$ $$ $$.1

diff --left-column $conf $bakdir/$confbak |tee $bakdir/${confbak}.log

