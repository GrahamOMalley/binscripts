#! /bin/bash

if test -z $1; then
    echo "Please supply host"; exit 0;
else
    HOST="$1"
fi


cat .ssh/id_rsa.pub | ssh $HOST 'cat >> .ssh/authorized_keys'


