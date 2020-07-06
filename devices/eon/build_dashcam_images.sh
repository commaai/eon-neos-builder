#!/bin/bash -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
OUT=$DIR/out
OTA=$DIR/ota

cd $DIR
source build_env.sh

mkdir -p $OUT/download
cd $OUT/download
$DIR/build_usr/download.py
cd $DIR

echo "Extracting and updating original NEOS base image" && echo
sudo umount $OUT/mnt || true
rm -rf $OUT/ota_tmp
mkdir -p $OUT/mnt $OUT/ota_tmp $OTA

# Unzip ota image and copy to out folder
unzip $OUT/download/ota-signed-latest.zip -d $OUT/ota_tmp
cp $OUT/ota_tmp/files/boot.img $OUT/boot.img
cp $OUT/ota_tmp/files/system.img $OUT/system.img

# Mount system.img and check out new dashcam-staging
sudo mount -o loop $OUT/system.img $OUT/mnt
sudo rm -rf $OUT/mnt/comma/openpilot
sudo git clone --branch=dashcam-staging --depth=1 https://github.com/commaai/openpilot.git $OUT/mnt/comma/openpilot
sudo umount $OUT/mnt

# Copy recovery.img from previous release
cp $OUT/download/recovery.img $DIR/out/recovery.img
