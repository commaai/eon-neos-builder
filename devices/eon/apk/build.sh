#!/bin/bash
set -e

# build userspace
./install.py

# Copy in configurations files
cp -R ../build_usr/usr/** out/data/data/com.termux/files/usr/

# Create apt folders
mkdir -p out/data/data/com.termux/files/usr/etc/apt/apt.conf.d/
mkdir -p out/data/data/com.termux/files/usr/etc/apt/preferences.d/
mkdir -p out/data/data/com.termux/files/usr/var/cache/apt/archives/partial
mkdir -p out/data/data/com.termux/files/usr/var/lib/dpkg/updates/
mkdir -p out/data/data/com.termux/files/usr/var/lib/dpkg/info
touch out/data/data/com.termux/files/usr/var/lib/dpkg/info/format-new
touch out/data/data/com.termux/files/usr/var/lib/dpkg/available
mkdir -p out/data/data/com.termux/files/usr/var/log/apt/

# Create tmp symlink
pushd out/data/data/com.termux/files/usr
ln -sf /tmp tmp
popd

# clone openpilot
cd /data/
if [ ! -d "/data/openpilot" ]; then
  git clone https://github.com/commaai/openpilot.git --recurse-submodules --depth 1 --branch pixel3
fi
