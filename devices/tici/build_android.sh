#!/bin/bash -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT=$DIR/../..
TOOLS=$ROOT/tools

cd $DIR

# install build tools
if [[ -z "${SKIP_DEPS}" ]]; then
    sudo apt-get install -y bc bison build-essential ccache curl flex g++-multilib gcc-multilib git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5-dev libsdl1.2-dev libssl-dev libwxgtk3.0-dev libxml2 libxml2-utils lzop openjdk-8-jdk pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev
fi

if [[ -z "${LIMIT_CORES}" ]]; then
  JOBS=$(nproc --all)
else
  JOBS=8
fi

# build mindroid
mkdir -p $DIR/android
cd $DIR/android
$TOOLS/repo init -u git@github.com:commaai/android.git -b tici-8
$TOOLS/repo sync -c -j$JOBS

./build.sh -j 32 sdm845

