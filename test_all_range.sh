#!/bin/bash

RANGES=(1 32 64 128)

for NUM_LAYER in {3..6}; do
  printf "Creating a $NUM_LAYER-layer database file...\n"
  sudo ./BPF-KV/simplekv /dev/nvme0n1 $NUM_LAYER create
  
  for RANGE_SIZE in ${RANGES[@]}; do
    total=0.0
    total_xrp=0.0
    total_csd=0.0
  
    count=1000
    echo "Running ./test_range.sh with NUM_LAYER=$NUM_LAYER, RANGE_SIZE=$RANGE_SIZE"
    for ((i=1; i<=count; i++)); do
      rm tmp.txt
    
      ./test_range.sh $NUM_LAYER $RANGE_SIZE > tmp.txt

      latencies=($(cat tmp.txt | grep "Range Size:" | awk '{print $(NF-1)}'))

      total=$(bc -l <<< "scale=6; $total + ${latencies[0]}")
      total_xrp=$(bc -l <<< "scale=6; $total_xrp + ${latencies[1]}")
      total_csd=$(bc -l <<< "scale=6; $total_csd + ${latencies[2]}")
    done

    # Calculate the average
    avg=$(bc -l <<< "scale=6; $total / $count")
    avg_xrp=$(bc -l <<< "scale=6; $total_xrp / $count")
    avg_csd=$(bc -l <<< "scale=6; $total_csd / $count")
  
    echo "num layer $NUM_LAYER" >> range_$RANGE_SIZE.txt
    echo "Average: $avg, $avg_xrp, $avg_csd" >> range_$RANGE_SIZE.txt
  done
done
