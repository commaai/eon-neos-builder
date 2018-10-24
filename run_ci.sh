#!/usr/bin/env bash
set -e

show_log() {
  tail -n 1000 log.txt
}

trap "show_log" ERR

{
./build_android.sh
./build_kernel_leeco.sh
./build_kernel_oneplus.sh
./make_boot.sh leeco
./make_boot.sh oneplus
./make_recovery.sh leeco
./make_recovery.sh oneplus
} > log.txt

tail -n 1000 log.txt

# TODO: Figure out mounting inside docker
# ./make_system.sh
