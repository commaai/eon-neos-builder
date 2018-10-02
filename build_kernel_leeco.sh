#!/bin/bash

export CROSS_COMPILE=$PWD/aarch64-linux-android-4.9/bin/aarch64-linux-android-
export ARCH=arm64

git clone https://github.com/commaai/android_kernel_leeco_msm8996.git --depth 1
cd android_kernel_leeco_msm8996
git pull

make zl1_defconfig
make -j$(nproc --all)
