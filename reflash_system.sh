#!/bin/bash
./build_android.sh && ./make_system.sh && fastboot flash system build/system.good.img && fastboot reboot
