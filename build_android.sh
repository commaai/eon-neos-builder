#!/bin/bash
mkdir -p android/system
cd android/system
repo init -u git@github.com:commaai/android.git
repo sync

source build/envsetup.sh
breakfast oneplus3
brunch oneplus3

