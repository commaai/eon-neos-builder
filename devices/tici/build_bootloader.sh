#!/bin/bash -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
OUT=$DIR/out
ROOT=$DIR/../..
TOOLS=$ROOT/tools

# Get EDK2 source
if [ ! -d edk2_tici ]; then
  git clone git@github.com:commaai/edk2_tici.git
fi
cd edk2_tici

# Install dependencies
$TOOLS/extract_toolchains.sh

# Create output directory
mkdir -p $OUT

# Set correct env variables for EDK2 build
export PRODUCT_OUT=$OUT
export TARGET_GCC_VERSION=4.9
export BUILD_TOOLS=$TOOLS
export ANDROID_TOOLCHAIN=$TOOLS/aarch64-linux-android-4.9/bin
export TARGET_OUT_INTERMEDIATES=out/intermediates

# Run build
make cleanall
#make -C BaseTools/Source/C
make -f Standalone.mk abl

#TODO: Use the correct CLANG compiler & figure out signing of intermediate abl.elf


