#! /bin/bash

conf=$HOME/.flexget/config.yml
tv_dir=$HOME/tv
torrent_dir=/media/twoTB1/videos/.autotorrents
rss=$HOME/scripts/rss.dat

list=( $(cat $rss ))

echo "feeds:" > $conf

for i in ${list[@]}
do
    IFS=",";
    set $i;
    showdir="$tv_dir/$1"
    if [ -d $showdir ]; then
	    echo "$showdir exists"
    else
	    echo "$showdir does NOT exist, creating..."
	    mkdir -p $showdir
    fi
    echo "  $1:" >> $conf
    echo "    rss: $2" >> $conf
    echo "    accept_all: yes" >> $conf
    echo "    deluge:" >> $conf
    echo "      path: $torrent_dir/" >> $conf
    echo "      movedone: $tv_dir/$1" >> $conf
done

