#!/bin/bash -e
#./build_android.sh
./build_ramdisk_boot.sh
./build_boot.sh
./build_system.sh
./build_vbmeta.sh

