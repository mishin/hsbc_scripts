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

. `dirname $0`/env.sh

function getnull {
i=0
while [ $i -lt $1 ]; do
echo N
i=$((i+1))
done |xargs |sed 's/ //g'
}

if [ $# -eq 0 ]; then
  exit 99
fi

case $1 in
treats) src=$root/treats_add7
        dest=$root/treats.dsx
        dir=HSBC_treats
        all=$dest/treats.dsx
;;
t)      src=$root/t_add8
        dest=$root/t.dsx
        dir=HSBC
        all=$dest/t.dsx
;;
esac


#cat >$all <<EOF
#BEGIN HEADER
#   CharacterSet "CP1252"
#   ExportingTool "Ascential DataStage Export"
#   ToolVersion "4"
#   ServerName "vmrhel"
#   ToolInstanceID "panlm"
#   MDISVersion "1.0"
#   Date "2000-05-27"
#   Time "21.22.36"
#   ServerVersion "7.5.1.A"
#END HEADER
#BEGIN DSTABLEDEFS
#EOF

cd $src

for i in * ; do
  out=$dest/$i.out
  echo $i |cut -c1 |read h
  cat >$out <<EOF
   BEGIN DSRECORD
      Identifier "$dir\\\\$h\\\\$i"
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

  cat "$i" |awk -F',' '{print $2" "$3" "$4" "$5" "$6}' |\
  while read coln type len int decimal ; do
    case $type in
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
       extended=1
       #precision=$len
       precision=255
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

    cat >>$out <<EOF
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
  cat >>$out <<EOF
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

done

#cat $dest/*.out >>$all
#echo "END DSTABLEDEFS" >>$all
#unix2dos $all



