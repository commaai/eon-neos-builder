#!/bin/bash -e
#./build_bootloader.sh
fastboot flash abl out/abl.elf
fastboot reboot

