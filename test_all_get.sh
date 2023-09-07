#!/bin/bash

# Loop from NUM_LAYER 1 to 5
if [ -n "$1" ]; then
  NUM_THREAD=$1
else
  NUM_THREAD=1  # Default value if $2 does not exist
fi

for NUM_LAYER in {1..5}; do
  rm tmp.txt
  echo "Running ./test_bpfkv.sh with NUM_LAYER=$NUM_LAYER"
  ./test_bpfkv.sh $NUM_LAYER $NUM_THREAD >> tmp.txt
  echo "num layer $NUM_LAYER" >> get_$NUM_THREAD.txt
  cat tmp.txt | grep usec >> get_$NUM_THREAD.txt
done