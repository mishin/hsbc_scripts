#!/usr/bin/ksh

# cat hub1/AFAFMJP |awk -F',' '{
# if(x!="")print x
# x=$2"   '"'|'"',"
# } 
# END {
# gsub(/\|/,"\\x0a",x)
# gsub(/,/,"",x)
# printf "%s",x;print ")"
# }'


if [ $# -ne 2 ]; then
  echo "usage: $0 [hub|tts] filename"
  exit 9
fi

type=$1
filename=$2
basedir=`dirname $0`
tmpdir=/tmp
conf=$basedir/0e.$type.conf
if [ ! -f $conf ]; then
  echo "$conf not found"
  exit 9
fi

tn=${filename##*/}
tn=${tn%%.*}
cat $conf |grep -q "^$tn,"
if [ $? -eq 0 ]; then
  $basedir/0e.sh $type $filename >/tmp/$$
  filename=/tmp/$$
fi

cat <<EOF
LOAD TABLE ${tn} (
EOF

awk -F',' '
BEGIN {
c1="\xc2"
c2="\xc2\x9f"
}

{
if(str!="") print str
{
  if($3~/A/&&$4<200){
  if($4%2==0){
    len=$4/2
  } else {
    len=($4-1)/2
  }
  nullstr="NULL ('"'"'"
  for(i=1;i<=len;i++){
    nullstr=nullstr c2
  }
  nullstr=nullstr"'"')"'"
  } else {
    if($3~/[PS]/&&$5>9&&$6==0){
      nullstr="NULL ('"'"'-9999999999999999999.'"'"')"
    } else {
      nullstr=""
    }
  }
  str=$2"  '"'|'"' "nullstr","
}
}

END {
gsub(/\|/,"\\x0a",str)
gsub(/,/,"",str)
printf "%s",str;print ")"
}

' $filename

echo "FROM '{tablename}'"

