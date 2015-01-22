#!/bin/bash

#IFS=$'\n'

binfolder='/usr/local/bin/'

# hash is 40 chars + 3 for underscore and two digit hour
torrents=$(${binfolder}rtcontrol -qo hash,uploaded is_complete=yes \
  | awk '{printf "*3\r\n$3\r\nSET\r\n$43\r\n"$1"_"strftime("%H")"\r\n$"length($2)"\r\n"$2"\r\n"}' \
  | ${binfolder}redis-cli --pipe)

#	> torrents.dat)
#  | ${binfolder}redis-cli --pipe)

#echo "$torrents"
#${binfolder}redis-cli --pipe
