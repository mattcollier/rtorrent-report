#!/bin/bash
# print a 0 padded list of hours given an arbitrary start position
  start=17
  counter=${start}
  echo "=====start================"
  for i in {0..23}; do
    paddedhour=$(printf %02d "${counter}")
    echo "${paddedhour}"
    if [[ "${counter}" == "23" ]]; then
      counter=0
    else
      (( counter++ ))
    fi
  done
  echo "==========finish=========="
