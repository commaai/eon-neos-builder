#!/bin/bash -e

./flash_boot.sh
./flash_recovery.sh
./flash_system.sh

fastboot erase userdata
fastboot format cache
fastboot reboot
