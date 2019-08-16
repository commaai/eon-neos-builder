#!/bin/bash

#OUT_DIR=android/out/target/product/tici
OUT_DIR=out
#OUT_DIR=~/Desktop/Thundercomm/out/target/product/sdm845

fastboot flash boot_a $OUT_DIR/boot.img
fastboot flash dtbo_a $OUT_DIR/dtbo.img
fastboot flash system_a $OUT_DIR/system.img
fastboot flash vendor_a $OUT_DIR/vendor.img
fastboot flash vbmeta_a $OUT_DIR/vbmeta.img

if [[! -z "${FLASH_B}" ]]; then
  fastboot flash boot_b $OUT_DIR/boot.img
  fastboot flash dtbo_b $OUT_DIR/dtbo.img
  fastboot flash system_b $OUT_DIR/system.simg
  fastboot flash vendor_b $OUT_DIR/vendor.simg
  fastboot flash vbmeta_b $OUT_DIR/vbmeta.img
fi

#fastboot format userdata
fastboot flash userdata $OUT_DIR/userdata.img
