#!/bin/bash

fastboot flash boot_a out/boot.img
fastboot flash dtbo_a out/dtbo.img
fastboot flash system_a out/system.simg
fastboot flash vendor_a out/vendor.simg
fastboot flash vbmeta_a out/vbmeta.img --disable-verity
fastboot format userdata

