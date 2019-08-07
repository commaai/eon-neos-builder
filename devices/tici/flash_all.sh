#!/bin/bash
#OUTPATH=android/out/target/product/sdm845
OUTPATH=out

fastboot flash boot $OUTPATH/boot.img
fastboot flash dtbo $OUTPATH/dtbo.img
fastboot flash system $OUTPATH/system.simg
fastboot flash vendor $OUTPATH/vendor.simg
fastboot flash vbmeta $OUTPATH/vbmeta.img --disable-verity
fastboot format userdata

