#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
cd "$DIR"

# extract ramdisk
sudo rm -rf boot_ramdisk
mkdir -p boot_ramdisk

pushd boot_ramdisk
  gunzip -c ../mindroid/system/out/target/product/oneplus3/ramdisk.img | sudo cpio -i

  echo "running populate ramdisk"

  # copy ramdisk files, include symlinks
  ln -s /system/bin bin
  ln -s /data/data/com.termux/files/home home
  ln -s /data/data/com.termux/files/tmp tmp
  ln -s /data/data/com.termux/files/usr usr
  sudo cp -v "$DIR"/ramdisk_common/* .
  echo "7" > VERSION
  touch EON

  # repack ramdisk
  rm ../ramdisk-boot.gz
  sudo find . | sudo cpio -o -H newc -O ../ramdisk-boot
  gzip ../ramdisk-boot
popd

