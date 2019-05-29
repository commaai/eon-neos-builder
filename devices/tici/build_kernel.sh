#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT=$DIR/../..
TOOLS=$ROOT/tools

if [ ! -d android_kernel_comma_sdm845 ]; then
  git clone git@github.com:commaai/android_kernel_comma_sdm845.git --depth 1
fi

export CROSS_COMPILE=$TOOLS/aarch64-linux-gnu-gcc/bin/aarch64-linux-gnu-
export ARCH=arm64

cd android_kernel_comma_sdm845
make sdm845_defconfig
make -j$(nproc --all)
cd ..

