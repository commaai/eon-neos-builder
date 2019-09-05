#!/bin/bash -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
OUT=$DIR/out
ROOT=$DIR/../..
TOOLS=$ROOT/tools

cd $DIR

./build_android.sh

mkdir -p $OUT


pushd $DIR/build_usr

if [ -z "$CLEAN_USR" ]; then
    ./pull_from_release.sh
else
    if [ -z "$STAGE2" ]; then
        sudo rm -rf out/
        ./install.py
        ./finish.sh
    else
        ./pull.sh
    fi
fi
popd

cd $DIR/mindroid

$TOOLS/simg2img $DIR/mindroid/system/out/target/product/oneplus3/system.img system.img.raw
mkdir -p mnt
sudo mount -o loop system.img.raw mnt
sudo mkdir -p mnt/comma
sudo cp -R ../build_usr/out/data/data/com.termux/files/usr mnt/comma

sudo sed -i 's/ro.adb.secure=1/ro.adb.secure=0/' mnt/build.prop
sudo sed -i 's/neos.vpn=1/neos.vpn=0/' mnt/build.prop

# Turn off in production
# echo "service.adb.tcp.port=5555" | sudo tee -a mnt/build.prop

sudo cp -Rv "$DIR/home" mnt/comma/home
sudo chmod 600 mnt/comma/home/.ssh/*
sudo chown root:root mnt/build.prop
sudo chmod 644 mnt/build.prop
sudo chmod 600 mnt/comma/home/.ssh/*
sudo chmod 600 -R mnt/comma/usr/etc/ssh
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
