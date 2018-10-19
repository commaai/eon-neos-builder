#!/bin/bash
mkdir -p build

cd bootloader
git clone git://codeaurora.org/platform/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8.git --depth 1 -b LA.BR.1.1.3.c4-01000-8x16.0 android-gcc
git clone --depth 1 git@github.com:commaai/lk_cici.git

# build
cd lk_cici
make -j4 msm8996 EMMC_BOOT=1 VERIFIED_BOOT=1 TOOLCHAIN_PREFIX=../android-gcc/bin/arm-eabi-

# sign
../signlk/signlk.sh -i=./build-msm8996/emmc_appsboot.mbn -o=../../build/emmc_appsboot.mbn -d

