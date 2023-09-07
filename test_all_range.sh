#!/bin/bash

# Loop from NUM_LAYER 1 to 5
if [ -n "$1" ]; then
  RANGE_SIZE=$1
else
  RANGE_SIZE=1  # Default value if $2 does not exist
fi

for NUM_LAYER in {3..5}; do
  printf "Creating a $NUM_LAYER-layer database file...\n"
  sudo ./BPF-KV/simplekv /dev/nvme0n1 $NUM_LAYER create
  
  total=0.0
  total_xrp=0.0
  total_csd=0.0
  
  count=1000
  echo "Running ./test_range.sh with NUM_LAYER=$NUM_LAYER, RANGE_SIZE=$RANGE_SIZE"
  for ((i=1; i<=count; i++)); do
    rm tmp.txt
    
    ./test_range.sh $NUM_LAYER $RANGE_SIZE > tmp.txt

    latencies=$(cat tmp.txt | grep "Range Size:" | awk '{print $(NF-1)}')
    # echo $latencies

    while read -r lat; do
        read -r lat_xrp
        read -r lat_csd
        break  # Break after reading the first three lines
    done <<< "$latencies"
    # echo "$lat, $lat_xrp, $lat_csd"

    total=$(bc -l <<< "scale=6; $total + $lat")
    total_xrp=$(bc -l <<< "scale=6; $total_xrp + $lat_xrp")
    total_csd=$(bc -l <<< "scale=6; $total_csd + $lat_csd")
  done

  # Calculate the average
  avg=$(bc -l <<< "scale=6; $total / $count")
  avg_xrp=$(bc -l <<< "scale=6; $total_xrp / $count")
  avg_csd=$(bc -l <<< "scale=6; $total_csd / $count")
  
  echo "num layer $NUM_LAYER" >> range_$RANGE_SIZE.txt
  echo "Average: $avg, $avg_xrp, $avg_csd" >> range_$RANGE_SIZE.txt
done