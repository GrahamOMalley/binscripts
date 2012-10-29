#! /bin/bash

for PAGE in `seq 1 $2`;
do
    wget -r -l0 -nd -A jpg -R .txt --ignore-tags=a $1$PAGE
done;

zip $3.cbz *.jpg
rm *.jpg *.txt*
echo DONE
