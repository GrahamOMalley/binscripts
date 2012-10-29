grep Downloading log | sed -e s/^.*Downloading://g > list.txt
while read line; do echo -e "$line"; flexget --seen="$line"; done < list.txt 
