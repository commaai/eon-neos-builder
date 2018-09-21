#!/bin/bash
set -e

# check that /usr is up to date
if [ ! -d usr ]; then
  git clone https://github.com/commaai/usr.git --depth 1
fi
(cd usr && git pull)

FIRMWARE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

mkdir -p build
pushd build
  mkdir -p system/mnt
  sudo umount system/mnt || true

  # prepare system image
  pushd system
    simg2img "$FIRMWARE_DIR"/mindroid/system/out/target/product/oneplus3/system.img system.img.raw
    mkdir -p mnt
    sudo mount -o loop system.img.raw mnt

    # copy the usr files
    echo "doing git copy with usr repo"
    sudo mkdir -p mnt/comma
    sudo cp -R "$FIRMWARE_DIR"/usr mnt/comma

    echo 'replacing properties'
    sudo sed -i 's/ro.adb.secure=1/ro.adb.secure=0/' mnt/build.prop
    sudo sed -i 's/neos.vpn=1/neos.vpn=0/' mnt/build.prop

    # copy the home files
    sudo cp -Rv "$FIRMWARE_DIR"/home mnt/comma/home
    sudo chmod 600 mnt/comma/home/.ssh/*

    # set permissions
    sudo chown root:root mnt/build.prop
    sudo chmod 644 mnt/build.prop
    sudo chmod 600 mnt/comma/usr/etc/ssh/*
    sudo chmod 600 mnt/comma/home/.ssh/*
    sudo chmod 600 mnt/comma/usr/etc/ssh/*

    # done with system
    sudo umount mnt
    img2simg system.img.raw ../system.good.img
  popd

popd
