#!/usr/bin/ksh

. `dirname $0`/env.sh

rm -f $rootdir/tmp/demopart*

demo_job=$rootdir/demo_job/date1.dsx
demo_job=$rootdir/demo_job/${tbtype}_demojob.dsx
demo_job=$rootdir/demo_job/day1_demojob.dsx
i=1
head=0
cat -n $demo_job  |grep -e 'BEGIN DSRECORD' -e 'END DSRECORD' |\
awk '{print $1}' |xargs -n 2 |\
while read a b ; do
  if [ $head -eq 0 ]; then
    n=$((a-1))
    cat $demo_job |sed -n "1,$n"p >$rootdir/tmp/demopart0.HEAD
    head=1
  fi
  cat $demo_job |sed -n "$a,$b"p |awk -F'"' '/^      Identifier/ {print $2}
                                    /^      Name / {print $2}' |xargs |read id na
  cat $demo_job |sed -n "$a,$b"p >$rootdir/tmp/demopart$i.$id.$na
  i=$((i+1))
done

cd $rootdir/tmp
root=$( ls *.ROOT.* )
db2stg=$( ls *.db2*sel )
db2no=$( echo $db2stg |cut -d'.' -f2 )
db2link1=$( ls demopart[0-9]*.$db2no*.lnkFROMdb2TOtfp )
transtg=$( ls *.tfpConvert )
transno=$( echo $transtg |cut -d'.' -f2 )
link1trans=$( ls demopart[0-9]*.$transno*.lnkFROMdb2TOtfp )
translink2=$( ls demopart[0-9]*.$transno*.lnkFROMtfpTOfsq )
outputstg=$( ls *.fsq*ort )
outputno=$( echo $outputstg |cut -d'.' -f2 )
link2output=$( ls demopart[0-9]*.$outputno*.lnkFROMtfpTOfsq )

echo $root $db2stg $db2link1 $translink2 $outputstg > $rootdir/tmp/seqlist

