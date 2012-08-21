#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -ne 1 ]; then
    echo "usage: $0 [hub|tts]"
    exit 9
fi

case $1 in
hub)
    export tts=0
;;
tts)
    export tts=1
;;
*)  
    echo "type err"
    exit 9
;;
esac

cd $rootdir/bin 2>/dev/null || exit

ls -d $rootdir/tb/* |wc -l |read totalfile
nowfile=0

for i in $rootdir/tb/* ; do
    nowfile=$((nowfile+1))
    if [ "x${i##*/}" == "xCVS" ]; then
      continue
    fi
    echo "Creating ${i##*/} ($nowfile/$totalfile) ..."
    ./split.sh
    tn=${i##*/}
    ./convert.sh $tn
    ./mod0.sh $tn
    ./mod1.sh $tn
    ./mod2.sh $tn
    ./mod3.sh $tn
    ./mod4.sh $tn
    ./mod5.sh $tn
    ./mod6.sh $tn
    ./concatenate.sh $tn
    ./modanno.sh $tn
    ./last.sh $tn
done

