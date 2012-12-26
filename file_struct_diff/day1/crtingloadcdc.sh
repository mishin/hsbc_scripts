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

cat <<EOF
LOAD TABLE ${1##*/}_o (
context               '|' null ,
agent_context         '|' null ,
timestamp             '|' null ,
operation             '|' null ,
tableName             '|' null ,
transactionID         '|' null ,
sequence              '|' null ,
journalCode           '|' null ,
entryType             '|' null ,
jobName               '|' null ,
userName              '|' null ,
jobNumber             '|' null ,
programName           '|' null ,
fileName              '|' null ,
libraryName           '|' null ,
memberName            '|' null ,
RRN                   '|' null ,
userProfile           '|' null ,
systemName            '|' null ,
referentialConstraint '|' null ,
trig                  '|' null ,
objectNameIndicator   '|' null ,
EOF


awk -F',' '
BEGIN {
c1="\xc2"
c2="\xc2\x9f"
c3="N"
c4="NN"
}

{
if(str!="") print str
{
  if($3~/A/&&$4<0){
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
    if($3~/[PS]/){
      nstr=""
      nstr2=""
      if($5>9&&$6==0){
        for(i=1;i<=$5;i++){
          nstr=nstr c3
        }
        nullstr="NULL ('"'"'-9999999999999999999.'"'"','"'"'"nstr"'"'"','"'"'"nstr c4"'"'"')"
      } else {
        if($6!=0){
          for(i=1;i<=$5-$6+1;i++){
            nstr=nstr c3
          }
          for(i=1;i<=$5+1;i++){
            nstr2=nstr2 c3
          }
          nullstr="NULL ('"'"'"nstr"'"'"','"'"'"nstr2"'"'"')"
        } else {
          for(i=1;i<=$5;i++){
            nstr=nstr c3
          }
          nullstr="NULL ('"'"'"nstr"'"'"','"'"'"nstr c4"'"'"')"
        }
      }
    } else {
      nullstr=""
    }
  }
  str=$2"  '"'|'"' "nullstr","
}
}

END {
gsub(/\|/,"\\x0a",str)
gsub(/,$/,"",str)
printf "%s",str;print ")"
}

' $1

echo "FROM '{tablename}'"

