#!/usr/bin/ksh

#tablename/col name/type/length(byte)/precision/floate.decimal/
# A Type A to indicate Character data.               SQL_CHAR 1
# B Type B to indicate Binary data.                  SQL_BINARY -2
# L Type L to indicate Date data.                    SQL_DATE 9
# O Type O to indicate DBCS-Open data.               Unicode string varchar 12
# P Type P to indicate Packed Decimal data.          SQL_DECIMAL 3 (int/bigint/decimal)
# S Type S to indicate Zoned Decimal data.           SQL_DECIMAL 3 (int/bitint/decimal)
# Z Type Z to indicate Time stamp data.              SQL_TIMESTAMP 11
# T ??                                               SQL_TIME 10
# F Type F to indicate Floating Point data.
# H Type H to indicate Hexadecimal data.
# J Type J to indicate DBCS-Only data.
# E Type E to indicate DBCS-Either data.
# G Type G to indicate DBCS-Graphic data.

#. `dirname $0`/env.sh

function getnull {
i=0
while [ $i -lt $1 ]; do
echo N
i=$((i+1))
done |xargs |sed 's/ //g'
}

if [ $# -ne 2 ]; then
  echo
  echo "usage: $0 [cdc|nocdc] src_dir/filename"
  echo "       $0 [cdc|nocdc] ./filename"
  echo
  exit 9
fi

type=$1
file=$2

if [ ! -f "$file" ]; then
  echo "file not found."
  exit 9
fi

echo ${file##*/} |cut -c1 |read h
cat <<EOF
   BEGIN DSRECORD
      Identifier "HSBC\\\\$h\\\\${file##*/}"
      DateModified "2000-05-27"
      TimeModified "13.31.16"
      OLEType "CMetaTable"
      Readonly "0"
      ShortDesc "Saved 5/25/2000 21:39:52"
      Version "8"
      QuoteChar "000"
      Multivalued "0"
      SPErrorCodes ";"
      Columns "CMetaColumn"
EOF

if [ "$type" == "cdc" ]; then
  cat <<EOF
      BEGIN DSSUBRECORD
         Name "context"
         SqlType "1"
         Precision "32"
         Scale "0"
         Nullable "1"
         KeyPosition "1"
         DisplaySize "32"
         LevelNo "0"
         Occurs "0"
         SignOption "0"
         SyncIndicator "0"
         PadChar ""
         ExtendedPrecision "0"
         TaggedSubrec "0"
         OccursVarying "0"
      END DSSUBRECORD
      BEGIN DSSUBRECORD
         Name "agent_context"
         SqlType "1"
         Precision "64"
         Scale "0"
         Nullable "1"
         KeyPosition "1"
         DisplaySize "64"
         LevelNo "0"
         Occurs "0"
         SignOption "0"
         SyncIndicator "0"
         PadChar ""
         ExtendedPrecision "0"
         TaggedSubrec "0"
         OccursVarying "0"
      END DSSUBRECORD
      BEGIN DSSUBRECORD
         Name "timestamp"
         SqlType "1"
         Precision "26"
         Scale "0"
         Nullable "1"
         KeyPosition "0"
         DisplaySize "26"
         LevelNo "0"
         Occurs "0"
         SignOption "0"
         SyncIndicator "0"
         PadChar ""
         ExtendedPrecision "0"
         TaggedSubrec "0"
         OccursVarying "0"
      END DSSUBRECORD
      BEGIN DSSUBRECORD
         Name "operation"
         SqlType "1"
         Precision "12"
         Scale "0"
         Nullable "1"
         KeyPosition "0"
         DisplaySize "12"
         LevelNo "0"
         Occurs "0"
         SignOption "0"
         SyncIndicator "0"
         PadChar ""
         ExtendedPrecision "0"
         TaggedSubrec "0"
         OccursVarying "0"
      END DSSUBRECORD
      BEGIN DSSUBRECORD
         Name "tableName"
         SqlType "1"
         Precision "64"
         Scale "0"
         Nullable "1"
         KeyPosition "0"
         DisplaySize "64"
         LevelNo "0"
         Occurs "0"
         SignOption "0"
         SyncIndicator "0"
         PadChar ""
         ExtendedPrecision "0"
         TaggedSubrec "0"
         OccursVarying "0"
      END DSSUBRECORD
      BEGIN DSSUBRECORD
         Name "transactionID"
         SqlType "1"
         Precision "24"
         Scale "0"
         Nullable "1"
         KeyPosition "0"
         DisplaySize "24"
         LevelNo "0"
         Occurs "0"
         SignOption "0"
         SyncIndicator "0"
         PadChar ""
         ExtendedPrecision "0"
         TaggedSubrec "0"
         OccursVarying "0"
      END DSSUBRECORD
      BEGIN DSSUBRECORD
         Name "sequence"
         SqlType "12"
         Precision "20"
         Scale "0"
         Nullable "1"
         KeyPosition "0"
         DisplaySize "20"
         LevelNo "0"
         Occurs "0"
         SignOption "0"
         SyncIndicator "0"
         PadChar ""
         ExtendedPrecision "0"
         TaggedSubrec "0"
         OccursVarying "0"
      END DSSUBRECORD
      BEGIN DSSUBRECORD
         Name "journalCode"
         SqlType "1"
         Precision "1"
         Scale "0"
         Nullable "1"
         KeyPosition "0"
         DisplaySize "1"
         LevelNo "0"
         Occurs "0"
         SignOption "0"
         SyncIndicator "0"
         PadChar ""
         ExtendedPrecision "0"
         TaggedSubrec "0"
         OccursVarying "0"
      END DSSUBRECORD
      BEGIN DSSUBRECORD
         Name "entryType"
         SqlType "1"
         Precision "2"
         Scale "0"
         Nullable "1"
         KeyPosition "0"
         DisplaySize "2"
         LevelNo "0"
         Occurs "0"
         SignOption "0"
         SyncIndicator "0"
         PadChar ""
         ExtendedPrecision "0"
         TaggedSubrec "0"
         OccursVarying "0"
      END DSSUBRECORD
      BEGIN DSSUBRECORD
         Name "jobName"
         SqlType "1"
         Precision "10"
         Scale "0"
         Nullable "1"
         KeyPosition "0"
         DisplaySize "10"
         LevelNo "0"
         Occurs "0"
         SignOption "0"
         SyncIndicator "0"
         PadChar ""
         ExtendedPrecision "0"
         TaggedSubrec "0"
         OccursVarying "0"
      END DSSUBRECORD
      BEGIN DSSUBRECORD
         Name "userName"
         SqlType "1"
         Precision "10"
         Scale "0"
         Nullable "1"
         KeyPosition "0"
         DisplaySize "10"
         LevelNo "0"
         Occurs "0"
         SignOption "0"
         SyncIndicator "0"
         PadChar ""
         ExtendedPrecision "0"
         TaggedSubrec "0"
         OccursVarying "0"
      END DSSUBRECORD
      BEGIN DSSUBRECORD
         Name "jobNumber"
         SqlType "1"
         Precision "6"
         Scale "0"
         Nullable "1"
         KeyPosition "0"
         DisplaySize "6"
         LevelNo "0"
         Occurs "0"
         SignOption "0"
         SyncIndicator "0"
         PadChar ""
         ExtendedPrecision "0"
         TaggedSubrec "0"
         OccursVarying "0"
      END DSSUBRECORD
      BEGIN DSSUBRECORD
         Name "programName"
         SqlType "1"
         Precision "10"
         Scale "0"
         Nullable "1"
         KeyPosition "0"
         DisplaySize "10"
         LevelNo "0"
         Occurs "0"
         SignOption "0"
         SyncIndicator "0"
         PadChar ""
         ExtendedPrecision "0"
         TaggedSubrec "0"
         OccursVarying "0"
      END DSSUBRECORD
      BEGIN DSSUBRECORD
         Name "fileName"
         SqlType "1"
         Precision "10"
         Scale "0"
         Nullable "1"
         KeyPosition "0"
         DisplaySize "10"
         LevelNo "0"
         Occurs "0"
         SignOption "0"
         SyncIndicator "0"
         PadChar ""
         ExtendedPrecision "0"
         TaggedSubrec "0"
         OccursVarying "0"
      END DSSUBRECORD
      BEGIN DSSUBRECORD
         Name "libraryName"
         SqlType "1"
         Precision "10"
         Scale "0"
         Nullable "1"
         KeyPosition "0"
         DisplaySize "10"
         LevelNo "0"
         Occurs "0"
         SignOption "0"
         SyncIndicator "0"
         PadChar ""
         ExtendedPrecision "0"
         TaggedSubrec "0"
         OccursVarying "0"
      END DSSUBRECORD
      BEGIN DSSUBRECORD
         Name "memberName"
         SqlType "1"
         Precision "10"
         Scale "0"
         Nullable "1"
         KeyPosition "0"
         DisplaySize "10"
         LevelNo "0"
         Occurs "0"
         SignOption "0"
         SyncIndicator "0"
         PadChar ""
         ExtendedPrecision "0"
         TaggedSubrec "0"
         OccursVarying "0"
      END DSSUBRECORD
      BEGIN DSSUBRECORD
         Name "RRN"
         SqlType "1"
         Precision "10"
         Scale "0"
         Nullable "1"
         KeyPosition "0"
         DisplaySize "10"
         LevelNo "0"
         Occurs "0"
         SignOption "0"
         SyncIndicator "0"
         PadChar ""
         ExtendedPrecision "0"
         TaggedSubrec "0"
         OccursVarying "0"
      END DSSUBRECORD
      BEGIN DSSUBRECORD
         Name "userProfile"
         SqlType "1"
         Precision "10"
         Scale "0"
         Nullable "1"
         KeyPosition "0"
         DisplaySize "10"
         LevelNo "0"
         Occurs "0"
         SignOption "0"
         SyncIndicator "0"
         PadChar ""
         ExtendedPrecision "0"
         TaggedSubrec "0"
         OccursVarying "0"
      END DSSUBRECORD
      BEGIN DSSUBRECORD
         Name "systemName"
         SqlType "1"
         Precision "8"
         Scale "0"
         Nullable "1"
         KeyPosition "0"
         DisplaySize "8"
         LevelNo "0"
         Occurs "0"
         SignOption "0"
         SyncIndicator "0"
         PadChar ""
         ExtendedPrecision "0"
         TaggedSubrec "0"
         OccursVarying "0"
      END DSSUBRECORD
      BEGIN DSSUBRECORD
         Name "referentialConstraint"
         SqlType "4"
         Precision "10"
         Scale "0"
         Nullable "1"
         KeyPosition "0"
         DisplaySize "11"
         LevelNo "0"
         Occurs "0"
         SignOption "0"
         SyncIndicator "0"
         PadChar ""
         APTFieldProp "quote=none"
         ExtendedPrecision "0"
         TaggedSubrec "0"
         OccursVarying "0"
      END DSSUBRECORD
      BEGIN DSSUBRECORD
         Name "trigger"
         SqlType "4"
         Precision "10"
         Scale "0"
         Nullable "1"
         KeyPosition "0"
         DisplaySize "11"
         LevelNo "0"
         Occurs "0"
         SignOption "0"
         SyncIndicator "0"
         PadChar ""
         APTFieldProp "quote=none"
         ExtendedPrecision "0"
         TaggedSubrec "0"
         OccursVarying "0"
      END DSSUBRECORD
      BEGIN DSSUBRECORD
         Name "objectNameIndicator"
         SqlType "1"
         Precision "1"
         Scale "0"
         Nullable "1"
         KeyPosition "0"
         DisplaySize "1"
         LevelNo "0"
         Occurs "0"
         SignOption "0"
         SyncIndicator "0"
         PadChar ""
         ExtendedPrecision "0"
         TaggedSubrec "0"
         OccursVarying "0"
      END DSSUBRECORD
EOF
fi

cat "$file" |sed 's///' |awk -F',' '{print $2" "$3" "$4" "$5" "$6}' |\
while read coln coltype len int decimal ; do
  case $coltype in
  A) sqltype=1
     extended=0
     precision=$len
     scale=0
     null=""
  ;;
  B) sqltype=-2
     extended=0
     precision=$len
     scale=0
     null=""
  ;;
  L) sqltype=9
     extended=0
     precision=$len
     scale=0
     null=""
  ;;
  O) sqltype=12
     # if coltype is "O", this column could contain chinese characters.
     # - when extract data from db2 to text, converting happens from utf8 to gbk
     # set this property (extended/unicode) to 1, it works properly in datastage 7.5
     # - when extract data from attunity cdc to text, no converting (from gbk to gbk)
     # set this property to 0
     if [ "$type" == "nocdc" ]; then
       extended=1
     else
       extended=0
     fi
     #precision=$len
     if [ $len -lt 200 ]; then
         precision=255
     else
         precision=$len
     fi
     scale=0
     null=""
  ;;
  P|S) if [ $decimal -eq 0 ]; then
         if [ $int -gt 9 ]; then
           #sqltype=-5
           sqltype=3
           getnull $((int+2)) |read null
         else
           sqltype=4
           getnull $int |read null
         fi
         extended=0
         precision=$int
         scale=$decimal
       else
         sqltype=3
         extended=0
         precision=$int
         scale=$decimal
         getnull $((int+1)) |read null
       fi
  ;;
  Z) sqltype=11
     extended=1
     precision=$len
     scale=0
     null=""
  ;;
  T) sqltype=10
     extended=0
     precision=$len
     scale=0
     null=""
  ;;
  esac

  cat <<EOF
      BEGIN DSSUBRECORD
         Name "$coln"
         SqlType "$sqltype"
         Precision "$precision"
         Scale "$scale"
         Nullable "1"
         KeyPosition "0"
         DisplaySize "$precision"
         LevelNo "0"
         Occurs "0"
         SignOption "0"
         SyncIndicator "0"
         PadChar ""
         APTFieldProp "quote=none, null_field='$null'"
         ExtendedPrecision "$extended"
         TaggedSubrec "0"
         OccursVarying "0"
      END DSSUBRECORD
EOF

done

cat <<EOF
      SEQ-Delimiter ","
      SEQ-QuoteChar "\\""
      SEQ-ColHeaders "0"
      SEQ-FixedWidth "0"
      SEQ-ColSpace "0"
      SEQ-OmitNewLine "0"
      AllowColumnMapping "0"
      PadChar ""
      APTRecordProp "final_delim=none, record_delim_string='\\\\r\\\\n', delim_string='#!'"
   END DSRECORD
EOF

