#!/usr/bin/ksh

if [ $# -ne 2 ]; then
  echo "usage: $0 [hub|tts] <dir_name>"
  exit 9
fi

type=$1
name=$2

case $type in
hub)
  proj=dpr_orc_prd
;;
tts)
  proj=dpr_orc_prd1
;;
*)
  echo "type is error"
  exit 9
;;
esac

for i in $name/* ; do
  tn=${i##*/}
  echo "oracle$name $proj $tn"
done > $name.list


