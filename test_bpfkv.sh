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
if [ ! -z $1 ]; then
    DEV_NAME=$1
fi
printf "DEV_NAME=$DEV_NAME\n"

DB_PATH=$DEV_NAME

# Check whether BPF-KV is built
if [ ! -e "$BPFKV_PATH/simplekv" ]; then
    printf "Cannot find BPF-KV binary. Please build BPF-KV first.\n"
    exit 1
fi

# Disable CPU frequency scaling
$UTILS_PATH/disable_cpu_freq_scaling.sh

pushd $BPFKV_PATH

printf "Creating a 5-layer database file...\n"
sudo ./simplekv $DB_PATH 5 create

printf "Running a short point lookup benchmark with regular file operation...\n"
sudo ./simplekv $DB_PATH 5 get --requests=20000

printf "Running a short point lookup benchmark with XRP enabled...\n"
sudo ./simplekv $DB_PATH 5 get --requests=20000 --use-xrp

printf "Running a short point lookup benchmark with csd resubmit...\n"
sudo ./simplekv $DB_PATH 5 get --requests=20000 --use-csd

popd
printf "Done.\n"
