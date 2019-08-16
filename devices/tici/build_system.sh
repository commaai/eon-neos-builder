#!/bin/bash -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
OUT=$DIR/out
TMP=$DIR/tmp
ROOT=$DIR/../..
TOOLS=$ROOT/tools

ANDROID=$DIR/android
#ANDROID=~/Desktop/Thundercomm/

AVBTOOL_DIR=$ANDROID/out/host/linux-x86/bin
export PATH=$AVBTOOL_DIR:$PATH
AVBTOOL=$AVBTOOL_DIR/avbtool

# Make output and tmp directories
cd $DIR
mkdir -p $OUT
mkdir -p $TMP

# Copy over system, vendor and userdata partitions
cp $ANDROID/out/target/product/tici/vendor.img $OUT/vendor.img
echo "Copied vendor.img to output directory"
cp $ANDROID/out/target/product/tici/userdata.img $OUT/userdata.img
echo "Copied userdata.img to output directory"
cp $ANDROID/out/target/product/tici/system.img $TMP/system.img
echo "Copied system.img to tmp directory"

# Remove footers
$AVBTOOL erase_footer --image $TMP/system.img
echo "Removed footers from system.img"

# De-sparsify system
$TOOLS/simg2img $TMP/system.img $TMP/system.img.raw
rm $TMP/system.img
echo "De-sparsified system.img"

# Modify system image
mkdir -p mnt
sudo mount -o loop $TMP/system.img.raw mnt
sudo mkdir -p mnt/system/comma
sudo cp -R ../eon/build_usr/out/data/data/com.termux/files/usr mnt/system/comma
sudo cp -Rv "$DIR/../eon/home" mnt/system/comma/home
sudo chmod 600 mnt/system/comma/home/.ssh/*
sudo chmod 600 -R mnt/system/comma/usr/etc/ssh
sudo ln -s /system/bin mnt/bin
sudo cp -v "$DIR"/ramdisk_common/* mnt/.  # ramdisk is now here
#sudo sh -c 'echo -e "\nimport /init.comma.rc" >> mnt/init.rc'
sudo mkdir mnt/tmp
sleep 1
sudo umount mnt
rm -rf mnt
echo "Modified system.img.raw"

# Sparsify image
$TOOLS/img2simg $TMP/system.img.raw $TMP/system.img
echo "Sparsified system.img.raw"

# Add hashtree footer to new system.img
$AVBTOOL add_hashtree_footer --image $TMP/system.img --partition_name system --partition_size 0xC0000000 --setup_as_rootfs_from_kernel
echo "Added hashtree footer to system.img"

# Copy over to output directory
cp $TMP/system.img $OUT/system.img

# Remove temporary directory
rm -r $TMP

# Print output message
GREEN="\033[0;32m"
NO_COLOR='\033[0m'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
echo -e "${GREEN}Output: ${BOLD}$OUT/system.img${NORMAL}${NO_COLOR}"


