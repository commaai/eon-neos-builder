#!/bin/bash -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
OUT=$DIR/out
OTA=$DIR/ota

cd $DIR
source build_env.sh

echo "Downloading existing NEOS OTA images from current dashcam branch" && echo
cd build_usr
./download.py
cd $DIR

echo "Extracting and updating original NEOS base image" && echo
sudo umount $OUT/mnt || true
rm -rf $OUT $OTA
mkdir -p $OUT/mnt $OUT/tmp $OTA

unzip build_usr/ota-signed-latest.zip -d $OTA
sudo mount -o loop $OTA/files/system.img $OUT/mnt

sudo rm -rf $OUT/mnt/comma/openpilot
sudo git clone --branch=dashcam-staging --depth=1 https://github.com/commaai/openpilot.git $OUT/mnt/comma/openpilot

sudo umount $OUT/mnt

# Staging for existing local flash and OTA prep scripts to function
cp build_usr/recovery.img $DIR/out/recovery.img
ln ota/files/boot.img out/boot.img
ln ota/files/system.img out/system.img