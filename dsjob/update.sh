#!/usr/bin/ksh

. /sysp/attun50/navroot/bin/nav_login.sh

tn=$1
istts=$2

case $istts in
0)
     echo $tn |cut -c1 |read h
     case $h in
     [A-G]) ds=aoc_oracle_test13_sa ;;
     [H-I]) ds=aoc_oracle_test15_sa ;;
     [L-Z]) ds=aoc_oracle_test12_sa ;;
     esac
;;
1)
     cat ttscdc.conf |grep "^$tn " |awk '{print $2}' |read ds
;;
*)
     echo "table type error"
     exit
;;
esac

if [ $istts -eq 0 ] && [ "$tn" == "LP@OGJP" -o "$tn" == "LP@OPJP" ]; then
  ds=aoc_oracle_test15_sa
  nav_util -b $ds execute $ds >> log/update.sh.log 2>/dev/null <<EOF
update table_context set context = tmpcontext where tablename = '$tn';
exit
EOF
else
  nav_util -b $ds execute $ds >> log/update.sh.log 2>/dev/null <<EOF
update table_context set context = tmpcontext where tablename = '$tn';
exit
EOF
fi


