#!/bin/bash -e
##./build_ramdisk_boot.sh
#./build_boot.sh
#fastboot flash boot_a out/boot.img
#fastboot flash dtbo_a out/dtbo.img
fastboot flash boot_a android/out/target/product/sdm845/boot.img
fastboot flash dtbo_a android/out/target/product/sdm845/dtbo.img

fastboot reboot
