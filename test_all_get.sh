#!/bin/bash

DEV_NAME='/dev/nvme0n1'

THREAD_ARRAY=(1 2 4 16 64)

for NUM_LAYER in {4..6}; do
  printf "Creating a $NUM_LAYER-layer database file...\n"
  sudo ./BPF-KV/simplekv $DEV_NAME $NUM_LAYER create

  for NUM_THREAD in ${THREAD_ARRAY[@]}; do
    [ -e tmp.txt ] && rm tmp.txt
    echo "Running ./test_bpfkv.sh with NUM_LAYER=$NUM_LAYER"
    ./test_bpfkv.sh $NUM_LAYER $NUM_THREAD >> tmp.txt
    echo "num layer $NUM_LAYER" >> get_$NUM_THREAD.txt
    cat tmp.txt | grep usec >> get_$NUM_THREAD.txt
   done
done
