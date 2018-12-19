#!/bin/bash -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
OUT=$DIR/out
ROOT=$DIR/../..
TOOLS=$ROOT/tools

cd $DIR

./build_android.sh

mkdir -p $OUT

# Bake in NEOS
cd $DIR/mindroid
if [ ! -d usr ]; then
  git clone https://github.com/commaai/usr.git --depth 1
fi
cd usr
git pull
cd ..

$TOOLS/simg2img $DIR/mindroid/system/out/target/product/oneplus3/system.img system.img.raw
mkdir -p mnt
sudo mount -o loop system.img.raw mnt
sudo mkdir -p mnt/comma
sudo cp -R usr mnt/comma
sudo sed -i 's/ro.adb.secure=1/ro.adb.secure=0/' mnt/build.prop
sudo sed -i 's/neos.vpn=1/neos.vpn=0/' mnt/build.prop
sudo cp -Rv "$DIR/home" mnt/comma/home
sudo chmod 600 mnt/comma/home/.ssh/*
sudo chown root:root mnt/build.prop
sudo chmod 644 mnt/build.prop
sudo chmod 600 mnt/comma/usr/etc/ssh/*
sudo chmod 600 mnt/comma/home/.ssh/*
sudo chmod 600 mnt/comma/usr/etc/ssh/*
sudo umount mnt
$TOOLS/img2simg system.img.raw $OUT/system.simg
mv system.img.raw $OUT/system.img

# Clean up
rm -rf mnt

# Print output message
GREEN="\033[0;32m"
NO_COLOR='\033[0m'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
echo -e "${GREEN}Output: ${BOLD}$OUT/system.img${NORMAL}${NO_COLOR}"
