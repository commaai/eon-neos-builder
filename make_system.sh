#!/bin/bash
set -e

# check that /usr is up to date
if [ ! -d usr ]; then
  git clone git@github.com:commaai/usr.git
fi
(cd usr && git pull)

mkdir -p build
pushd build
  mkdir -p system/mnt
  sudo umount system/mnt || true

  # prepare system image
  pushd system
    simg2img system.img system.img.raw
    mkdir -p mnt
    sudo mount -o loop system.img.raw mnt

    ../../populate_system.sh mnt/

    sudo chown root:root mnt/build.prop
    sudo chmod 644 mnt/build.prop
    sudo chmod 600 mnt/comma/usr/etc/ssh/*
    sudo chmod 600 mnt/comma/home/.ssh/*

    if [[ $LEECO ]]; then
      echo "copying LeEco files"
      sudo cp -vp ../../lepatch/a530_zap.mdt mnt/etc/firmware/
      sudo cp -vp ../../lepatch/WCNSS_qcom_cfg.ini mnt/etc/wifi/
      sudo cp -vp ../../lepatch/mixer_paths_tasha.xml mnt/etc/
      sudo cp -vp ../../lepatch/audio_platform_info.xml mnt/etc/
    fi

    # done with system
    sudo umount mnt
    img2simg system.img.raw ../system.good.img
  popd

popd
