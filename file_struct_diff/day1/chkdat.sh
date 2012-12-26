#!/usr/bin/ksh

if [ $# -ne 1 ]; then
  echo "$0 hub1"
  exit 9
fi

img=$1
rm -f $img.nullist
rm -f $img.nulldat
rm -f $img.0e.job
rm -f $img.0e.rows

# check 0e data
>$img.nullist
rm -fr tmp/$img
mkdir tmp/$img

for i in $img/* ; do
  ./chk0e.sh $img ${i##*/}
done

#
# filter large table list
#
#if [ "$img" == "hub1" ] || [ "$img" == "hub2" ] \
#   || [ "$img" == "hub3" ] || [ "$img" == "hub4" ] || [ "$img" == "hub5" ] \
#   || [ "$img" == "hub6" ];then
# ./filter.sh $img.list
#fi

if [ "${img//[0-9]/}" == "hub" ];then
  ./filter.sh $img.list
fi

