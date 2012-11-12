#! /bin/bash

# need to get range and possibly regexp from args

if [ -z $1 ];then echo Give number of seasons; exit 0;fi

mv */* .;

for d in {1...$1};
do
    rm_empties;
    mkdir season_$d;
    mv *s0$d* season_$d;
done;

