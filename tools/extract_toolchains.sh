#!/bin/bash -e

# Sources:
# https://developer.arm.com/open-source/gnu-toolchain/gnu-a/downloads
# https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/+archive/master.tar.gz
# https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/+archive/master.tar.gz

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
THIS_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"

cd $DIR

LINARO_GCC=aarch64-linux-gnu-gcc
LINARO_GCC_PREFIX=gcc-arm
GOOGLE_GCC_4_9=aarch64-linux-android-4.9
GOOGLE_GCC_4_8_32BIT=arm-eabi-4.8

if [ ! -f $LINARO_GCC_PREFIX*.xz ] || \
   [ ! -f $GOOGLE_GCC_4_9*.gz ] || \
   [ ! -f $GOOGLE_GCC_4_8_32BIT*.gz ]; then
  git lfs install
  git lfs pull
fi

LINARO_GCC_TARBALL=$(find . -name $LINARO_GCC_PREFIX*.xz)
GOOGLE_GCC_4_9_TARBALL=$(find . -name $GOOGLE_GCC_4_9*.gz)
GOOGLE_GCC_4_8_32BIT_TARBALL=$(find . -name $GOOGLE_GCC_4_8_32BIT*.gz)

# Delete the old extracted toolchains if they need to be updated
if [ $THIS_SCRIPT -nt $LINARO_GCC ] || \
   [ $THIS_SCRIPT -nt $GOOGLE_GCC_4_9 ] || \
   [ $THIS_SCRIPT -nt $GOOGLE_GCC_4_8_32BIT ] || \
   [ $LINARO_GCC_TARBALL -nt $LINARO_GCC ] || \
   [ $GOOGLE_GCC_4_9_TARBALL -nt $GOOGLE_GCC_4_9 ] || \
   [ $GOOGLE_GCC_4_8_32BIT_TARBALL -nt $GOOGLE_GCC_4_8_32BIT ]; then
  rm -rf $LINARO_GCC
  rm -rf $GOOGLE_GCC_4_9
  rm -rf $GOOGLE_GCC_4_8_32BIT
fi

if [ ! -d $LINARO_GCC ]; then
  mkdir $LINARO_GCC
  tar -xJf $LINARO_GCC_TARBALL -C $LINARO_GCC --strip 1 &>/dev/null
fi

if [ ! -d $GOOGLE_GCC_4_9 ]; then
  mkdir $GOOGLE_GCC_4_9
  tar -xzf $GOOGLE_GCC_4_9_TARBALL -C $GOOGLE_GCC_4_9 &>/dev/null
fi

if [ ! -d $GOOGLE_GCC_4_8_32BIT ]; then
  mkdir $GOOGLE_GCC_4_8_32BIT
  tar -xzf $GOOGLE_GCC_4_8_32BIT_TARBALL -C $GOOGLE_GCC_4_8_32BIT &>/dev/null
fi

echo "Toolchains extracted!"
