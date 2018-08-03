#!/bin/bash
git clone https://github.com/commaai/android_kernel_leeco_msm8996.git --depth 1
cd android_kernel_leeco_msm8996
git pull

export PATH=/opt/android-ndk/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin:$PATH

CROSS_COMPILE=aarch64-linux-android- ARCH=arm64 make lineage_zl1_defconfig
CROSS_COMPILE=aarch64-linux-android- ARCH=arm64 make -j8

