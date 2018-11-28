#!/bin/bash -e

./flash_boot.sh
./flash_recovery.sh
./flash_system.sh

fastboot format userdata
fastboot format cache
fastboot reboot

