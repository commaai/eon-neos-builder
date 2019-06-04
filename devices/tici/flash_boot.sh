#!/bin/bash
./build_boot.sh
fastboot flash boot out/boot.img
fastboot reboot

