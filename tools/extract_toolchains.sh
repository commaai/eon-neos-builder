#!/bin/bash -e

# Sources:
# https://mirrors.edge.kernel.org/archlinux/community/os/x86_64/aarch64-linux-gnu-binutils-*.pkg.tar.xz
# https://mirrors.edge.kernel.org/archlinux/community/os/x86_64/aarch64-linux-gnu-gcc-*.pkg.tar.xz
# https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/+archive/master.tar.gz
# https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/+archive/master.tar.gz

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

LATEST_FSF_BINUTILS=aarch64-linux-gnu-binutils
LATEST_FSF_GCC=aarch64-linux-gnu-gcc
GOOGLE_GCC_4_9=aarch64-linux-android-4.9
GOOGLE_GCC_4_8_32BIT=arm-eabi-4.8

LATEST_FSF_BINUTILS_TARBALL=$(find $DIR -name $LATEST_FSF_BINUTILS*.xz)
LATEST_FSF_GCC_TARBALL=$(find $DIR -name $LATEST_FSF_GCC*.xz)
GOOGLE_GCC_4_9_TARBALL=$(find $DIR -name $GOOGLE_GCC_4_9*.gz)
GOOGLE_GCC_4_8_32BIT_TARBALL=$(find $DIR -name $GOOGLE_GCC_4_8_32BIT*.gz)

if [ ! -d $DIR/$LATEST_FSF_GCC ]; then
  mkdir $DIR/$LATEST_FSF_GCC
  tar -xJf $LATEST_FSF_GCC_TARBALL -C $DIR/$LATEST_FSF_GCC
  tar -xJf $LATEST_FSF_BINUTILS_TARBALL -C $DIR/$LATEST_FSF_GCC
fi

if [ ! -d $DIR/$GOOGLE_GCC_4_9 ]; then
  mkdir $DIR/$GOOGLE_GCC_4_9
  tar -xzf $GOOGLE_GCC_4_9_TARBALL -C $DIR/$GOOGLE_GCC_4_9
fi

if [ ! -d $DIR/$GOOGLE_GCC_4_8_32BIT ]; then
  mkdir $DIR/$GOOGLE_GCC_4_8_32BIT
  tar -xzf $GOOGLE_GCC_4_8_32BIT_TARBALL -C $DIR/$GOOGLE_GCC_4_8_32BIT
fi
