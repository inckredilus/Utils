#!/bin/sh
# go and do something in utils or just cd
#
DO="$1"
DIR="/storage/emulated/0/Prog/Utils/"

if [ -z "$DO" ]; then
   cd $DIR
else
   sh /storage/emulated/0/Prog/Utils/$DO
fi

alias g='. /storage/emulated/0/g'

