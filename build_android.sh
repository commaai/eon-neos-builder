#!/bin/bash
mkdir -p mindroid/system
cd mindroid/system
../../tools/repo init -u https://github.com/commaai/android.git -b mindroid
../../tools/repo sync

sudo apt-get install openjdk-8-jdk

source build/envsetup.sh
breakfast oneplus3
make -j

