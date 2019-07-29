#!/bin/bash
OUTPATH=android/out/target/product/sdm845

fastboot flash boot $OUTPATH/boot.img
fastboot flash dtbo $OUTPATH/dtbo.img
fastboot flash system $OUTPATH/system.img
fastboot flash vbmeta $OUTPATH/vbmeta.img --disable-verity
fastboot flash vendor $OUTPATH/vendor.img

