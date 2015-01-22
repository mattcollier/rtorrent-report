#/bin/bash
for hour in $(seq 0 23); do
  echo "Top 10 for Hour: ${hour}"
  column=$(( hour + 3 ))
  sort -nrk${column},${column} --field-separator=$'\t' data/twentyfour.dat | head -10 | awk 'BEGIN { FS = "\t" };{print $'${column}'"\t" $2}'
  echo
done

