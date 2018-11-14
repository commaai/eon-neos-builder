#!/bin/bash -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
OUT=$DIR/out
ROOT=$DIR/../..
TOOLS=$ROOT/tools

export EMMC_BOOT=1
export VERIFIED_BOOT=1
export TOOLCHAIN_PREFIX=$TOOLS/arm-eabi-4.8/bin/arm-eabi-

$TOOLS/extract_toolchains.sh
mkdir -p $OUT

cd $DIR/bootloader

if [ ! -d lk_cici ]; then
  git clone git@github.com:commaai/lk_cici.git --depth 1
fi

# Build lk
cd lk_cici
make msm8996 -j$(nproc --all)

# Sign lk
../signlk/signlk.sh -i=./build-msm8996/emmc_appsboot.mbn -o=$OUT/emmc_appsboot.mbn -d
