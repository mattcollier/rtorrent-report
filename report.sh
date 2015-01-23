#!/bin/bash

# requires a redis server running on localhost an a working pyrocode/rtcontrol installation

IFS=$'\n'

source "${HOME}/settings.conf"

# housekeeping
if [ -d "${datafolder}" ]; then
  if [ -f "${datafolder}${datafile}" ]; then
    rm "${datafolder}${datafile}"
  fi 
else
  mkdir -p "${datafolder}"
fi

# hash is 40 chars + 3 for underscore and two digit hour
header="hash,name,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23"
if ${showheader}; then 
  echo "${header}"
fi
for torrent in $(${binfolder}rtcontrol -qo hash,name is_complete=yes alias="${trackeralias}"); do
  hash=$(echo "${torrent}" | cut -f1)
  name=$(echo "${torrent}" | cut -f2) 
  uploaddata=$(${binfolder}redis-cli MGET ${hash}_00 ${hash}_01 ${hash}_02 ${hash}_03 ${hash}_04 \
    ${hash}_05 ${hash}_06 ${hash}_07 ${hash}_08 ${hash}_09 ${hash}_10 ${hash}_11 ${hash}_12 \
    ${hash}_13 ${hash}_14 ${hash}_15 ${hash}_16 ${hash}_17 ${hash}_18 ${hash}_19 ${hash}_20 \
    ${hash}_21 ${hash}_22 ${hash}_23 ${hash}_24)
  lowestnumber=$(echo "${uploaddata}" | sort | head -1) 
  hourseries=
  counter=0
  lownumber=0
  for hourdata in ${uploaddata}; do
    if [[ "${lowestnumber}" == "${hourdata}" ]]; then
      lownumber=${lowestnumber}
    fi
    if (( "${lownumber}" <= "${hourdata}" )); then
      hourdiff=$(expr ${hourdata} - ${lownumber})
    fi
    lownumber=${hourdata}
    hourdiffmegs=$(echo "scale=2; ${hourdiff} / 1048576" | bc )
    if [[ "${counter}" == "0" ]]; then
      hourseries=${hourdiffmegs}
    else
      hourseries="${hourseries}\t${hourdiffmegs}"
    fi
    ((counter++))
  done
  echo -e "\"${hash}\"\t\"${name}\"\t${hourseries}" >> "${datafolder}${datafile}"
done

