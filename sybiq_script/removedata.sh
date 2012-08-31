#!/bin/ksh
# script name:removedata.sh
# Remove data files from definite directory  
# -------------------------------
# Initialize avariables
# -------------------------------
DIR=/sybiq/script/backup
TIMESTAMP=`date +%Y%m%d%H%M%S`
LOG_NAME=$DIR/log/removed.${TIMESTAMP}.log
KEY_NAME=TXT.orig.gz

# -------------------------------
# List all files in $DIR directory
#+and redirect to log
# -------------------------------
find "$DIR" -name "*.${KEY_NAME}" -type f -atime +7 -exec ls {} \; > $LOG_NAME
find "$DIR" -name "*.${KEY_NAME}" -type f -atime +7 -exec rm -f {} \; 

# -------------------------------
# finished the script
# -------------------------------

exit 0
