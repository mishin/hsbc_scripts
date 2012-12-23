#!/bin/ksh

. `dirname $0`/env.sh

proj=dpr_orc_dev

dsjob -ljobs "$proj" |grep -e ^Ongoing -e ^Day1 -e ^Date 2>/dev/null |while read job ; do
  echo "$job\c"
  dsjob -jobinfo "$proj" "$job" 2>/dev/null |grep -e "Job Status" -e "Last Run Time" |\
awk -F": " '{printf",%s",$2} END {printf"\n"}'


done


exit

#dsjob -report panlm job_schedual
