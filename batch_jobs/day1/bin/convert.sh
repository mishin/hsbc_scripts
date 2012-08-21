#!/usr/bin/ksh

. `dirname $0`/env.sh

if [ $# -eq 0 ]; then
  exit
fi

tn=$1
cp -f $rootdir/tb/$tn $rootdir/tmp/tb

cd $rootdir/tmp
rm -f tb.*
rm -f part*

cat tb |awk -F'"' '/^  *Name/ {if($2~/[#@$]/)print$2}' >tb.sharp

#i=1
#gethead=0
#cat -n tb |grep -e "BEGIN DSSUBRECORD" -e "END DSSUBRECORD" |awk '{print $1}' |xargs -n 2 |\
#while read a b ; do
#  if [ $gethead -eq 0 ]; then
#    n=$((a-1))
#    cat tb |sed -n "1,$n"p >head
#    gethead=1
#  fi
#  cat tb |sed -n "$a,$b"p >part$i
#  echo part$i >>tb.filelist
#  i=$((i+1))
#done

cat tb |awk 'BEGIN {i=0}
/^      BEGIN DSSUBRECORD/,/^      END DSSUBRECORD/{
if($0~/^  *BEGIN DSSUBRECORD/){
i+=1
print "part"i > "tb.filelist"
}
print > "part"i
}'

cat tb.filelist |while read file ; do
  cat $file |awk -F'"' '/Name / {print $2}' |read name
  cat $file |awk -F'"' '/SqlType / {print $2}' |read sqltype
  cat $file |awk -F'"' '/Precision / {print $2}' |read precision
  cat $file |awk -F'"' '/Scale / {print $2}' |read scale
  cat $file |awk -F'"' '/Nullable / {print $2}' |read nullable
  cat $file |awk -F'"' '/KeyPosition / {print $2}' |read keyposition
  cat $file |awk -F'"' '/DisplaySize / {print $2}' |read displaysize
  cat $file |awk -F'"' '/PadChar / {print $2}' |read padchar
  cat $file |awk -F'"' '/APTFieldProp / {print $2}' |read aptfieldprop
  cat $file |awk -F'"' '/ExtendedPrecision / {print $2}' |read extended

  if [ "x" = "x$extended" ]; then
    extended=0
  fi

  #create format1 file
  f1=tb.f1
  echo "$name" >>$f1

: <<EOF #{{{
#create format2 file
f2=tb.f2
case $sqltype in 
-10) type="ustring[max=$precision]" ;;
-9)  type="ustring[max=$precision]" ;;
-8)  type="ustring[$precision]" ;;
-7)  type="uint16" ;;
-6)  if [ $extended -eq 1 ]; then
       type="uint8"
     else
       type="int8"
     fi
;;
-5)  if [ $extended -eq 1 ]; then
       type="uint64"
     else
       type="int64"
     fi
;;
-4)  type="raw[max=$precision]" ;;
-3)  type="raw[max=$precision]" ;;
-2)  type="raw[$precision]" ;;
-1)  if [ $extended -eq 1 ]; then
       type="ustring[max=$precision]"
     else
       type="string[max=$precision]"
     fi
;;
0)   type="ustring" ;;
1)   if [ $extended -eq 1 ]; then
       type="ustring[$precision]"
     else
       type="string[$precision]"
     fi
;;
2)   type="decimal[$precision,$scale]" ;;
3)   type="decimal[$precision,$scale]" ;;
4)   if [ $extended -eq 1 ]; then
       type="uint32"
     else
       type="int32"
     fi
;;
5)   if [ $extended -eq 1 ]; then
       type="uint16"
     else
       type="int16"
     fi
;;
6)   type="sfloat" ;;
7)   type="sfloat" ;;
8)   type="dfloat" ;;
9)   type="date" ;;
10)  if [ $extended -eq 1 ]; then
       type="time[microseconds]"
     else
       type="time"
     fi
;;
11)  if [ $extended -eq 1 ]; then
       type="timestamp[microseconds]"
     else
       type="timestamp"
     fi
;;
12)  if [ $extended -eq 1 ]; then
       type="ustring[max=$precision]"
     else
       type="string[max=$precision]"
     fi
;;
*)   type=NULL ;;
esac

case $nullable in
1) type2="nullable $type" ;;
0) type2="not_nullable $type" ;;
esac

echo "  $name:$type2=$name;" >>$f2

#create format3 file
f3=tb.f3
case $nullable in
1)
  type3="nullable $type"
;;
0)
  type3="$type"
;;
esac
if [ "x$aptfieldprop" != "x" ]; then
  type3="$type3 {$aptfieldprop}"
fi
echo "  $name:$type3;" >>$f3

#create format4 file
f4=tb.f4
case $nullable in
1)
  type4="nullable $type"
;;
0)
  type4="$type"
;;
esac
echo "  $name:$type4;" >>$f4
EOF
#}}}

done

# create sql from format1
sed -i '2,$s/^/,/' $f1

# vim:foldmethod=marker:foldenable:foldlevel=0

