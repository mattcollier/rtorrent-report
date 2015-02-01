#!/bin/bash

IFS=$','

source "${HOME}/settings.conf"

hash="$1"
uploaddata="$(${binfolder}redis-cli --csv MGET ${hash}_00 ${hash}_01 ${hash}_02 ${hash}_03 ${hash}_04 \
  ${hash}_05 ${hash}_06 ${hash}_07 ${hash}_08 ${hash}_09 ${hash}_10 ${hash}_11 ${hash}_12 \
  ${hash}_13 ${hash}_14 ${hash}_15 ${hash}_16 ${hash}_17 ${hash}_18 ${hash}_19 ${hash}_20 \
  ${hash}_21 ${hash}_22 ${hash}_23 | tr -d '"')"

counter=0
for hourdata in ${uploaddata}; do
  echo -e "${counter}\t${hourdata}"
  (( counter ++ ))
done
