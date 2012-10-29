#!/bin/bash

#convert flacs to mp3s in current dir

for FILE in *.flac;
do NEWFILE=`echo $FILE | sed -e s/.flac//g -e s/$/.mp3/g` ;
	ffmpeg -i $FILE -acodec mp3 -ab 128k $NEWFILE
done
