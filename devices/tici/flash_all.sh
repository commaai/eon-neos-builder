#!/bin/bash

fastboot flash boot_a out/boot.img
fastboot flash dtbo_a out/dtbo.img
fastboot flash system_a out/system.simg
fastboot flash vendor_a out/vendor.simg
fastboot flash vbmeta_a out/vbmeta.img

if [[! -z "${FLASH_B}" ]]; then
  fastboot flash boot_b out/boot.img
  fastboot flash dtbo_b out/dtbo.img
  fastboot flash system_b out/system.simg
  fastboot flash vendor_b out/vendor.simg
  fastboot flash vbmeta_b out/vbmeta.img
fi

fastboot format userdata
