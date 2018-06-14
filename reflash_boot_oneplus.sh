#!/bin/bash
./build_kernel_oneplus.sh && ./make_boot.sh oneplus && $(fastboot oem 4F500301; true) && fastboot flash boot build/bootnew.img && fastboot reboot

