#!/bin/bash

for f in *.mp3;
do
n=`id3v2 -l $f | grep TIT2 | cut -f4-9 -d " "   | tr [A-Z] [a-z] | sed -e 's/ /_/g;s/\[//g;s/\]//g' | sed -e 's/_explicit//g'`;
mv $f $n.mp3;
done;
