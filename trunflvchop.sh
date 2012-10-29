#!/bin/bash

#cunningly make it take either one arg or no arg - 
#one arg -> series name -> append to front of file name
#no args -> just strip out the chars

for FILE in *.flv*;
do NEWFILE=`echo $FILE | sed -e s/[^0-9]//g | cut -c 1-8 |sed -e s/$/.flv/g` ;
 if [ -n "$1" ]
 then
 NEWFILE=$1-$NEWFILE
 fi
 echo "$FILE will be renamed as $NEWFILE" ;
 mv "$FILE" "$NEWFILE" ;
done
