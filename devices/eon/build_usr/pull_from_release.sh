#!/usr/bin/env sh
set -e

./download.py
sudo umount files/mnt || true
sudo rm -rf files

unzip ota-signed-latest.zip files/system.img
mkdir files/mnt
sudo mount -o loop files/system.img files/mnt

sudo rm -rf out/
mkdir -p out/data/data/com.termux/files/usr
sudo rsync -av files/mnt/comma/usr out/data/data/com.termux/files/

sudo umount files/mnt
