#!/bin/bash -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
OUT=$DIR/out
ROOT=$DIR/../..
TOOLS=$ROOT/tools

cd $DIR

mkdir -p $OUT

# Install build tools
if [[ -z "${SKIP_DEPS}" ]]; then
    sudo apt-get install -y cpio openjdk-8-jdk git-core gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev libxml2-utils xsltproc unzip python bc android-tools-fsutils
fi

# Build mindroid
mkdir -p $DIR/mindroid/system
cd $DIR/mindroid/system
$TOOLS/repo init -u https://github.com/commaai/android.git -b mindroid
$TOOLS/repo sync -c -j$(nproc --all)

set +e
source build/envsetup.sh
set -e
breakfast oneplus3

if [[ -z "${LIMIT_CORES}" ]]; then
    make -j$(nproc --all)
else
    make -j8
fi

# Bake in NEOS
cd $DIR/mindroid
if [ ! -d usr ]; then
  git clone https://github.com/commaai/usr.git --depth 1
fi
pushd usr
  git pull
popd

$TOOLS/simg2img $DIR/mindroid/system/out/target/product/oneplus3/system.img system.img.raw
mkdir -p mnt
sudo mount -o loop system.img.raw mnt
sudo mkdir -p mnt/comma
sudo cp -R usr mnt/comma
sudo sed -i 's/ro.adb.secure=1/ro.adb.secure=0/' mnt/build.prop
sudo sed -i 's/neos.vpn=1/neos.vpn=0/' mnt/build.prop
sudo chmod 600 mnt/comma/home/.ssh/*
sudo chown root:root mnt/build.prop
sudo chmod 644 mnt/build.prop
sudo chmod 600 mnt/comma/usr/etc/ssh/*
sudo chmod 600 mnt/comma/home/.ssh/*
sudo chmod 600 mnt/comma/usr/etc/ssh/*
sudo umount mnt
$TOOLS/img2simg system.img.raw $OUT/system.img

# Print output message
GREEN="\033[0;32m"
NO_COLOR='\033[0m'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
echo -e "${GREEN}Output: ${BOLD}$OUT/system.img${NORMAL}${NO_COLOR}"
