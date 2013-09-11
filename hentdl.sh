#! /bin/bash

for PAGE in `seq 1 $2`;
do
    if [ "$PAGE" -lt 10 ];
    then 
        echo $10$PAGE
        wget -r -l0 -nd -A jpg -R .txt --ignore-tags=a $10$PAGE.jpg
    else
        echo $1$PAGE
        wget -r -l0 -nd -A jpg -R .txt --ignore-tags=a $1$PAGE.jpg
    fi;

    #wget -r -l0 -nd -A jpg -R .txt --ignore-tags=a $1$PAGE
done;

zip $3.cbz *.jpg
rm *.jpg *.txt*
echo DONE
