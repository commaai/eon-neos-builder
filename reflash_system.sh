#!/bin/bash
./build_android.sh && ./make_system.sh && $(fastboot oem 4F500301; true) && fastboot flash system build/system.good.img && fastboot reboot
