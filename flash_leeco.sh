#!/bin/bash

fastboot flash boot build/bootnew.img
fastboot flash system build/system.good.img
fastboot format userdata
fastboot format cache
fastboot reboot

