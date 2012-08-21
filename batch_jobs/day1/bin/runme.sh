#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -ne 2 ]; then
  echo "usage: $0 [hub|tts] [day1|date|date1|date2]"
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
  echo "type error"
  exit 9
;;
esac

case $2 in
day1|date|date1|date2)
  export tbtype=$2
;;
*)
  echo "tbtype:$2 is error"
  exit 9
;;
esac

ls -d $rootdir/tb/* |wc -l |read totalfile
nowfile=0

cd $rootdir/bin 2>/dev/null ||exit

for i in $rootdir/tb/* ; do
  nowfile=$((nowfile+1))
  if [ "x${i##*/}" == "xCVS" ]; then
    continue
  fi

  echo "Creating ${i##*/} ($nowfile/$totalfile) ..."
  tn=${i##*/}

  # # setting tbtype
  # if [ $day1 -eq 1 ];then
  #   export tbtype=day1
  # else
  #   cat $rootdir/etc/tmzfld.conf |awk '{if($1=="'"$tn"'")print$3}' |read a
  #   if [ "$a" == "Z" ]; then
  #     export tbtype=date1
  #   else
  #     export tbtype=date2
  #   fi
  # fi

  # save column's hex value which hexed
  if [ $tts -eq 1 ]; then
    export etctype=tts
  else
    export etctype=hub
  fi
  cat $rootdir/etc/0e.$etctype.conf |grep -q "^$tn,"
  if [ $? -eq 0 ]; then
    ./modstruct.sh $tn
  fi

  ./split.sh
  ./convert.sh $tn
  ./mod0.sh $tn
  ./mod1.sh $tn
  ./mod2.sh $tn
  ./mod3.sh $tn
  ./mod4.sh $tn
  ./mod5.sh $tn
  ./concatenate.sh $tn
  ./modannomulti.sh $tn
  ./last.sh $tn

done

