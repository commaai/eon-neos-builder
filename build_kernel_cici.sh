#!/bin/bash
git clone git@github.com:commaai/android_kernel_cici_msm8996.git --depth 1
cd android_kernel_cici_msm8996
git pull

export CROSS_COMPILE=/opt/android-ndk/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin/aarch64-linux-android-
export ARCH=arm64

make cici_defconfig
make -j$(nproc --all)
