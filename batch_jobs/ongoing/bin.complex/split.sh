#!/usr/bin/ksh

. `dirname $0`/env.sh

rm -f $rootdir/demo_job/part*

#demo_job=$rootdir/demo_job/hsbc_demo_modify_compile.dsx
demo_job=$rootdir/demo_job/ongoing_demojob.dsx
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
odbc1=`ls *.odbc1`
tmp=${odbc1#*.}
tmp=${tmp%.*}
odbc1link1=`ls part[0-9]*.$tmp*.link1`
trans=`ls *.transformer`
tmp=${trans#*.}
tmp=${tmp%.*}
link1trans=`ls part[0-9]*.$tmp*.link1`
translink2=`ls part[0-9]*.$tmp*.link2`
translink3=`ls part[0-9]*.$tmp*.link3`
output=`ls *.output`
tmp=${output#*.}
tmp=${tmp%.*}
link2output=`ls part[0-9]*.$tmp*.link2`
sort=`ls *.sort`
tmp=${sort#*.}
tmp=${tmp%.*}
sortlink4=`ls part[0-9]*.$tmp*.link4`
rd=`ls *.rd`
tmp=${rd#*.}
tmp=${tmp%.*}
rdlink5=`ls part[0-9]*.$tmp*.link5`
odbc2=`ls *.odbc2`
tmp=${odbc2#*.}
tmp=${tmp%.*}
link5odbc2=`ls part[0-9]*.$tmp*.link5`


echo $root $odbc1link1 $link1trans $translink2 $translink3 $sortlink4 $rdlink5 $link5odbc2 > $rootdir/demo_job/seqlist



