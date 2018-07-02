#!/bin/bash
scp build/bootnew.img phone:/sdcard/bootnew.img
ssh phone "dd if=/sdcard/bootnew.img of=/dev/block/bootdevice/by-name/boot && reboot"

