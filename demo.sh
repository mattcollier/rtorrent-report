#!/bin/bash

IFS=$'\n'

uploaddata=$'\n\n\n\n\n\n1000'

echo "=============== for method ==============="
counter=0
for hourdata in "${uploaddata}"; do
  echo -e "${counter}\t${hourdata}"
  (( counter ++ ))
done
echo "=============== while method ==============="
counter=0
while read -r hourdata; do
  echo -e "${counter}\t${hourdata}"
  (( counter ++ ))
done <<< "${uploaddata}"
