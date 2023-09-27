#!/bin/bash
if [ "$(uname -r)" !=  "5.12.0-xrp+" ]; then
    printf "Not in XRP kernel. Please run the following commands to boot into XRP kernel:\n"
    printf "    sudo grub-reboot \"Advanced options for Ubuntu>Ubuntu, with Linux 5.12.0-xrp+\"\n"
    printf "    sudo reboot\n"
    exit 1
fi

SCRIPT_PATH=`realpath $0`
BASE_DIR=`dirname $SCRIPT_PATH`
BPFKV_PATH="$BASE_DIR/BPF-KV"
UTILS_PATH="$BASE_DIR/utils"

DEV_NAME="/dev/nvme0n1"
printf "DEV_NAME=$DEV_NAME\n"

NUM_LAYER=$1

NUM_THREAD=$2

# Check whether BPF-KV is built
if [ ! -e "$BPFKV_PATH/simplekv" ]; then
    printf "Cannot find BPF-KV binary. Please build BPF-KV first.\n"
    exit 1
fi

# Disable CPU frequency scaling
#$UTILS_PATH/disable_cpu_freq_scaling.sh

pushd $BPFKV_PATH

if [ -n "$3" ]; then
  printf "Creating a $NUM_LAYER-layer database file...\n"
  sudo ./simplekv $DEV_NAME $NUM_LAYER create
fi

printf "Running a short point lookup benchmark with regular file operation...\n"
sudo ./simplekv $DEV_NAME $NUM_LAYER get --requests=10000 --thread=$NUM_THREAD

printf "Running a short point lookup benchmark with XRP enabled...\n"
sudo ./simplekv $DEV_NAME $NUM_LAYER get --requests=10000 --use-xrp --thread=$NUM_THREAD

printf "Running a short point lookup benchmark with csd resubmit...\n"
sudo ./simplekv $DEV_NAME $NUM_LAYER get --requests=10000 --use-csd --thread=$NUM_THREAD

popd
printf "Done.\n"
