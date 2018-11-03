#!/usr/bin/env bash
set -e

LIMIT_CORES=1 ./build_android.sh
./build_kernel_leeco.sh
./build_kernel_oneplus.sh
./make_boot.sh leeco
./make_boot.sh oneplus
./make_recovery.sh leeco
./make_recovery.sh oneplus

# TODO: Figure out mounting inside docker
# ./make_system.sh
