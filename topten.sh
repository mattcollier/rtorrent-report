#/bin/bash

source "${HOME}/settings.conf"

for hour in $(seq 0 23); do
  echo "Top 10 for Hour: ${hour}"
  column=$(( hour + 3 ))
  sort -nrk${column},${column} --field-separator=$'\t' "${datafolder}${datafile}" \
    | head -10 | awk -F'\t' '{ if ($'${column}' > 0) print $'${column}',"\t",$2 }'
  echo
done

