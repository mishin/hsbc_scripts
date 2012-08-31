#!/usr/bin/ksh

if [ $# -ne 2 ]; then
  exit
fi

rootdir=/sybiq/script
base=$1

echo "===" >>$rootdir/ftp.log
ftp -vin >>$rootdir/ftp.log <<EOF
open 133.2.95.85
user ftpuser ftpuser
bin
lcd $rootdir/$base
cd /$base
prompt
mput $2.[a-z]*
bye
EOF


