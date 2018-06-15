#!/bin/bash

fastboot flash boot build/bootnew_leeco.img
fastboot flash recovery build/recoverynew_leeco.img
fastboot flash system build/system.good.img
fastboot format userdata
fastboot format cache
fastboot reboot

