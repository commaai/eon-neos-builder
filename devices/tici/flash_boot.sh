#!/bin/bash -e
./build_ramdisk_boot.sh
./build_boot.sh
fastboot flash boot out/boot.img
fastboot flash dtbo out/dtbo.img
fastboot reboot

