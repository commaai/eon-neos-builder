#!/bin/bash -e

fastboot oem 4F500301 || true

./flash_boot.sh
./flash_recovery.sh
./flash_system.sh

fastboot erase userdata
fastboot format cache
fastboot reboot
