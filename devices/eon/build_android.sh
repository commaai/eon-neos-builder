#!/bin/bash -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT=$DIR/../..
TOOLS=$ROOT/tools

cd $DIR

# install build tools
if [[ -z "${SKIP_DEPS}" ]]; then
    sudo apt-get install -y cpio openjdk-8-jdk git-core gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev libxml2-utils xsltproc unzip python bc android-tools-fsutils
fi

if [[ -z "${LIMIT_CORES}" ]]; then
  JOBS=$(nproc --all)
else
  JOBS=8
fi

# build mindroid
mkdir -p $DIR/mindroid/system
cd $DIR/mindroid/system
$TOOLS/repo init -u https://github.com/commaai/android.git -b mindroid
$TOOLS/repo sync -c -j$JOBS

(source build/envsetup.sh && breakfast oneplus3 && make -j$JOBS)

