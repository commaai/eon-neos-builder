#!/bin/bash
./build_kernel_cici.sh && ./make_boot.sh cici && fastboot flash boot build/bootnew_cici.img && fastboot reboot

