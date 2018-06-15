#!/bin/bash

fastboot oem 4F500301
fastboot flash boot build/bootnew_oneplus.img
fastboot flash recovery build/recoverynew_oneplus.img
fastboot flash system build/system.good.img
fastboot flash LOGO logo.bin

fastboot erase userdata
fastboot format cache
fastboot reboot

