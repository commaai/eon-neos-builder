#!/usr/bin/env bash

./build_android.sh
./build_kernel_oneplus.sh
./make_boot.sh oneplus
./make_recovery.sh oneplus
./make_system.sh
