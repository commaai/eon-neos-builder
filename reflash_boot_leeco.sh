#!/bin/bash
./build_kernel_leeco.sh && ./make_boot.sh leeco && fastboot flash boot build/bootnew.img && fastboot reboot

