#!/usr/bin/ksh

. `dirname $0`/env.sh

rm -f $rootdir/demo_job/part*

demo_job=$rootdir/demo_job/copy_demojob.dsx

i=1
head=0
cat -n $demo_job  |grep -e 'BEGIN DSRECORD' -e 'END DSRECORD' |\
awk '{print $1}' |xargs -n 2 |\
while read a b ; do
  if [ $head -eq 0 ]; then
    n=$((a-1))
    cat $demo_job |sed -n "1,$n"p >$rootdir/demo_job/part0.HEAD
    head=1
  fi
  cat $demo_job |sed -n "$a,$b"p |awk -F'"' '/^      Identifier/ {print $2}
                                    /^      Name / {print $2}' |xargs |read id na
  cat $demo_job |sed -n "$a,$b"p >$rootdir/demo_job/part$i.$id.$na
  i=$((i+1))
done

cd $rootdir/demo_job
root=`ls *.ROOT.*`
db2=`ls *.db2`
tmp=${db2#*.}
tmp=${tmp%.*}
db2link1=`ls part[0-9]*.$tmp*.link1`
copy=`ls *.copy`
tmp=${copy#*.}
tmp=${tmp%.*}
link1copy=`ls part[0-9]*.$tmp*.link1`
copylink2=`ls part[0-9]*.$tmp*.link2`
output=`ls *.output`
tmp=${output#*.}
tmp=${tmp%.*}
link1output=`ls part[0-9]*.$tmp*.link2`

echo $root $db2link1 $copylink2 > $rootdir/demo_job/seqlist




