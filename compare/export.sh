#!/bin/ksh
# For export data from Sybase IQ 
if [ $# -ne 1 ];then
  echo "Usage:$0 table_name"
  exit 9
fi
exit 9
# -------------------------------------
# Initailize
# -------------------------------------
DATASTR=$(date +%Y%m%d%H%M%S)
BCP_PATH=/sybiq/ASIQ-12_7/bin
EXPORT_PATH=/sybiq/script/compare
TABLE_NAME=SSMLTNP
USERNAME=hsbc
PASSWD=hsbc
DATABASENAME=hsbcdw
SERVERNAME=hsbcdw

# -------------------------------------
# Be sure that iq_bcp tool can be found 
# -------------------------------------
if [ ! -f $BCP_PATH/iq_bcp ];then
  echo "bcp tool is not exist"
  exit 9
fi

# -------------------------------------
# Start export data
# -------------------------------------
#$BCP_PATH/iq_bcp ${DATABASENAME}.${USERNAME}.${TABLE_NAME} out \
#  $EXPORT_PATH/${TABLE_NAME}.${DATASTR}.TXT \
#  -c -U $USERNAME -P $PASSWD -S $SERVERNAME

