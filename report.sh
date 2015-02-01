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
steptime=0
for torrent in $(${binfolder}rtcontrol -qo hash,name is_complete=yes alias="${trackeralias}"); do
  hash=$(echo "${torrent}" | cut -f1)
  name=$(echo "${torrent}" | cut -f2)
  uploaddata=$(${binfolder}redis-cli --csv MGET ${hash}_00 ${hash}_01 ${hash}_02 ${hash}_03 ${hash}_04 \
    ${hash}_05 ${hash}_06 ${hash}_07 ${hash}_08 ${hash}_09 ${hash}_10 ${hash}_11 ${hash}_12 \
    ${hash}_13 ${hash}_14 ${hash}_15 ${hash}_16 ${hash}_17 ${hash}_18 ${hash}_19 ${hash}_20 \
    ${hash}_21 ${hash}_22 ${hash}_23 | tr -d '"' )

  start=$( date +%k )
  if (( start == 23 )); then
    counter=0
  else
    counter=$(( start + 1 ))
  fi
  seqdata=
  for i in {0..23}; do
    # paddedhour=$(printf %02d "${counter}")
    fieldnum=$(( counter + 1 ))
    hourdata=$( echo "${uploaddata}" | cut -f ${fieldnum} -d ',' )
    if [[ "${hourdata}" == "NIL" ]]; then
      hourdata=0
    fi
    seqdata="${seqdata}${hourdata}"
    if (( i < 23 )); then
      seqdata="${seqdata}"$'\n'
    fi
    if [[ "${counter}" == "23" ]]; then
      counter=0
    else
      (( counter++ ))
    fi
  done
  # the first line should generally contain the lowest value except for new torrents which require the sort
  lowestnumber=$(echo "${seqdata}" | sort -n | head -1)
  # echo -e "${hash}\tlowest: ${lowestnumber}"
  hourseries=, 
  counter=0
  lownumber=0
#  T="$(date +\"%s.%3N\")"
  while read -r hourdata; do
    if [[ "${lowestnumber}" == "${hourdata}" ]]; then
      lownumber=${lowestnumber}
    fi
    if (( lownumber <= hourdata )); then
      hourdiff=$(( hourdata - lownumber ))
    fi
    lownumber=${hourdata}
    if [[ "${hourdiff}" > "0" ]]; then
      hourdiffmegs=$(echo "${hourdiff}" | awk '{printf "%f", $1 / 1048576}')
    else
      hourdiffmegs=0
    fi
    if [[ "${counter}" == "0" ]]; then
      hourseries=${hourdiffmegs}
    else
      hourseries="${hourseries}\t${hourdiffmegs}"
    fi
    ((counter++))
  done <<< "${seqdata}"
#  steptime=$(echo -e "$(date +\"%s.%3N\")\t$T" | awk -F'\t' '{gsub(/"/, "", $1);gsub(/"/, "", $2);printf "%f", $1 - $2}')
#  echo "${steptime}"
  echo -e "\"${hash}\"\t\"${name}\"\t${hourseries}" >> "${datafolder}${datafile}"
done

