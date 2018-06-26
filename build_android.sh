#!/bin/bash
mkdir -p mindroid/system
cd mindroid/system
../../tools/repo init -u https://github.com/commaai/android.git -b mindroid
../../tools/repo sync

sudo apt-get install -y openjdk-8-jdk git-core gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev libxml2-utils xsltproc unzip

source build/envsetup.sh
breakfast oneplus3
make -j

