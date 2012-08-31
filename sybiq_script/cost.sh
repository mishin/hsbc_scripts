#!/usr/bin/ksh
#
# ***********************************************************
# ScriptName	: cost.sh
# Author 	: Yue Yantao
# Date		: 2009-06-19
# Version	: 0.3
# Purpose	: calculate the usage about CPU and Storage
# Usage		: run this script without any agrument
# ***********************************************************

if [ $# -ne 3 ];then
  echo "Usage:  `basename $0` {cpu|main} Year Month"
  echo "exp.    `basename $0` cpu 2009 06"
  exit
fi

# ----------------------------
# Set envurinment variable 
#+to execute sql query below
# ----------------------------
. /sybiq/SYBASE.sh

type=$1
start=$2
end=$3
for i in  $startdate $enddate ;do
  num1=`echo $i |tr -d '[A-z]'|wc -c`
  num2=`echo $i |tr -d '[0-9]'|wc -c`
  if [ ${num1} -ne 9 ] || [ ${num2} -ne 1 ];then
    echo "Illegal date value : $i"
    exit 9
  fi
done

# -------------------------------------------
# Get the SQL
# tables : OS_GLOBALSTATS
#	 : SYBASEIQ_IQSTORAGE
# -------------------------------------------
function cpuquery_old {
 echo "select avg(C_CURRENT)/100 from OS_GLOBALSTATS where C_METRICNAME like '%CPU [%]%' \
and C_SAMPLE_TIME between '$1' and '$2' \
and substr(cast(C_SAMPLE_TIME as varchar),12,2) between '$3' and '$4' "
 echo "go"
}

function peakcpuquery {
 echo "select avg(C_CURRENT)/100 from OS_GLOBALSTATS where C_METRICNAME like '%CPU [%]%' \
and C_CURRENT >=15 \
and C_SAMPLE_TIME >= '$1' and  C_SAMPLE_TIME<= '$2'"
 echo "go"
}

function wholedaycpuquery {
 echo "select avg(C_CURRENT)/100 from OS_GLOBALSTATS where C_METRICNAME like '%CPU [%]%' \
and C_SAMPLE_TIME >= '$1' and  C_SAMPLE_TIME<= '$2'"
 echo "go"
}

function iqmainquery {
 echo "select max(C_USAGE) from SYBASEIQ_IQSTORAGE \
where C_NAME='Main' and C_SAMPLE_TIME >= '$1' and  C_SAMPLE_TIME<= '$2'"
 echo "go"
}

function iqmainstatus {
 echo "sp_iqstatus"
 echo "go"
}
function getdate {
 if [ $# -ne 2 ];then
   echo "function getdate illegal agruments"
   exit
 fi
 cal $2 $1 |sed '/[A-z]/d;/^$/d;s/ \([0-9] \)/0\1/g'|awk '{print$1" "$NF}'|\
	while read startdt enddt;do
   echo "$1-$2-$startdt $1-$2-$enddt"
 done
}

# -------------------------------------------
# Get the avg CPU and current IQ Main Storage
# -------------------------------------------
case $type in
 cpu)
   echo "\tWeek Date\tPeak Hours\tWhole Day"
   echo "----------------------------------------------------"
   getdate $start $end|while read startdate enddate ;do
        echo "$startdate/$enddate\t\c"
   	peakcpuquery $startdate $enddate >cpu.peak.sql
   	peak=`conn <cpu.peak.sql|awk '/---/{getline;print $1}'` && rm -f cpu.peak.sql
   	wholedaycpuquery $startdate $enddate >cpu.wholeday.sql
   	whole=`conn <cpu.wholeday.sql|awk '/---/{getline;print $1} ` && rm -f cpu.wholeday.sql
	echo "$peak\t$whole"
        echo "----------------------------------------------------"
   done
  ;;
 main)
   #iqmainquery $startdate $enddate >main.$$.sql  
   #conn <main.$$.sql && rm -f main.$$.sql
   iqmainstatus >main.$$.sql
   conn < main.$$.sql |awk '{if($0~/Main IQ Blocks Used:/){getline;print}}'|\
	awk -F'[,=]' '{print $3}' |read iqmain && rm -f main.$$.sql

   df -Pk 2>/dev/null |grep sybiq |awk '{total+=$2;usage+=$3}END\
        {printf "%0.2f\t%0.2f",total/1024/1024,usage/1024/1024}'|read filetotal fileusage 
   echo "Sybase IQ Main Usage 	: $iqmain"
   iqmain=`echo $iqmain|tr -d '[A-z]'`
   echo "scale=2;$iqmain+$fileusage"|bc |read all
   echo "Total Usage		: ${all}Gb"
  ;;
 *)
   echo "Illegal type : $type"
   exit 9
esac
 
exit 0

