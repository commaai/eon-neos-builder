#!/bin/bash -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
OUT=$DIR/out
ROOT=$DIR/../..
TOOLS=$ROOT/tools

cd $DIR
mkdir -p $OUT

#ANDROID=$DIR/android
ANDROID=/raid/thundercomm/android

$TOOLS/simg2img $ANDROID/out/target/product/sdm845/system.img system.img.raw
$TOOLS/simg2img $ANDROID/out/target/product/sdm845/vendor.img $OUT/vendor.img

mkdir -p mnt
sudo mount -o loop system.img.raw mnt
sudo mkdir -p mnt/system/comma
sudo cp -R ../eon/build_usr/out/data/data/com.termux/files/usr mnt/system/comma
sudo cp -Rv "$DIR/../eon/home" mnt/system/comma/home
sudo chmod 600 mnt/system/comma/home/.ssh/*
sudo chmod 600 -R mnt/system/comma/usr/etc/ssh
sudo ln -s /system/bin mnt/bin

# ramdisk is now here
sudo cp -v "$DIR"/ramdisk_common/* mnt/.
#sudo sh -c 'echo -e "\nimport /init.comma.rc" >> mnt/init.rc'

sudo mkdir mnt/tmp
sudo umount mnt
mv system.img.raw $OUT/system.img
#$TOOLS/img2simg $OUT/system.img $OUT/system.simg

# Clean up
rm -rf mnt

# Print output message
GREEN="\033[0;32m"
NO_COLOR='\033[0m'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
echo -e "${GREEN}Output: ${BOLD}$OUT/system.img${NORMAL}${NO_COLOR}"

export PATH=android/out/host/linux-x86/bin:$PATH
android/out/host/linux-x86/bin/avbtool add_hashtree_footer --image $OUT/system.img \
  --partition_name system --partition_size 3221225472 --setup_as_rootfs_from_kernel
echo "added hashtree footers"
$TOOLS/img2simg $OUT/system.img $OUT/system.simg
echo "remade simg"

android/out/host/linux-x86/bin/avbtool add_hashtree_footer --image $OUT/vendor.img \
  --partition_name vendor --partition_size 1073741824
$TOOLS/img2simg $OUT/vendor.img $OUT/vendor.simg
echo "did vendor"


