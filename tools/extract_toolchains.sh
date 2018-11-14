#!/bin/bash -e

# Sources:
# https://mirrors.edge.kernel.org/archlinux/community/os/x86_64/aarch64-linux-gnu-binutils-*.pkg.tar.xz
# https://mirrors.edge.kernel.org/archlinux/community/os/x86_64/aarch64-linux-gnu-gcc-*.pkg.tar.xz
# https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/+archive/master.tar.gz
# https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/+archive/master.tar.gz

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
THIS_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"

cd $DIR

LATEST_FSF_BINUTILS=aarch64-linux-gnu-binutils
LATEST_FSF_GCC=aarch64-linux-gnu-gcc
GOOGLE_GCC_4_9=aarch64-linux-android-4.9
GOOGLE_GCC_4_8_32BIT=arm-eabi-4.8

LATEST_FSF_BINUTILS_TARBALL=$(find . -name $LATEST_FSF_BINUTILS*.xz)
LATEST_FSF_GCC_TARBALL=$(find . -name $LATEST_FSF_GCC*.xz)
GOOGLE_GCC_4_9_TARBALL=$(find . -name $GOOGLE_GCC_4_9*.gz)
GOOGLE_GCC_4_8_32BIT_TARBALL=$(find . -name $GOOGLE_GCC_4_8_32BIT*.gz)

# Delete the old extracted toolchains if they need to be updated
if [ $THIS_SCRIPT -nt $LATEST_FSF_GCC ] || \
   [ $THIS_SCRIPT -nt $GOOGLE_GCC_4_9 ] || \
   [ $THIS_SCRIPT -nt $GOOGLE_GCC_4_8_32BIT ] || \
   [ $LATEST_FSF_BINUTILS_TARBALL -nt $LATEST_FSF_GCC ] || \
   [ $LATEST_FSF_GCC_TARBALL -nt $LATEST_FSF_GCC ] || \
   [ $GOOGLE_GCC_4_9_TARBALL -nt $GOOGLE_GCC_4_9 ] || \
   [ $GOOGLE_GCC_4_8_32BIT_TARBALL -nt $GOOGLE_GCC_4_8_32BIT ]; then
  rm -rf $LATEST_FSF_GCC
  rm -rf $GOOGLE_GCC_4_9
  rm -rf $GOOGLE_GCC_4_8_32BIT
fi

if [ ! -d $LATEST_FSF_GCC ]; then
  mkdir $LATEST_FSF_GCC
  tar -xJf $LATEST_FSF_GCC_TARBALL -C $LATEST_FSF_GCC &>/dev/null
  tar -xJf $LATEST_FSF_BINUTILS_TARBALL -C $LATEST_FSF_GCC &>/dev/null

  if [ -z "$(ldconfig -p | grep libmpfr.so.6)" ]; then
    echo "libmpfr.so.6 not found, editing GCC to use libmpfr.so.4 instead"
    find $LATEST_FSF_GCC -type f -executable -exec sed -i "s/libmpfr.so.6/libmpfr.so.4/g" {} \;
  fi
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
